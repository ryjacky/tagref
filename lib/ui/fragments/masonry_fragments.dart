import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/helpers/TwitterAPIDesktopHelper.dart';
import 'package:tagref/helpers/TwitterAPIHelper.dart';
import 'package:tagref/helpers/UpdateNotifier.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/isar/IsarHelper.dart';
import 'package:tagref/isar/TagRefSchema.dart';
import 'package:tagref/ui/screen/ScaledImageViewer.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

import '../components/image_widgets.dart';

typedef OnTagListChanged = Function();

class TagRefMasonryFragment extends StatefulWidget {
  final UpdateNotifier updateNotifier;

  const TagRefMasonryFragment({Key? key, required this.updateNotifier})
      : super(key: key);

  @override
  State<TagRefMasonryFragment> createState() => TagRefMasonryFragmentState();
}

class TagRefMasonryFragmentState extends State<TagRefMasonryFragment> {
  final IsarHelper _isarHelper = IsarHelper();
  late final GoogleApiHelper _gApiHelper;

  SearchTags searchTags = [];

  List<ImageData> imageData = [];

  final String notifierId = "TagRefMasonryFragment";

  @override
  void initState() {
    super.initState();
    _isarHelper.openDB().then((value) => update());

    widget.updateNotifier.addOnUpdateListener((callerId, type, data) {
      if (callerId == notifierId) return;

      if (type == UpdateType.searchChanged) searchTags = data;
      update();
    });
  }

  /// Update the masonry view to display image that satisfy the search.
  /// Show all when no filter/keyword is applied.
  ///
  /// Return true when successfully updated the view.
  Future<bool> update() async {
    dev.log("TagRefMasonry update()");
    late List<ImageData> queryResult;

    if (searchTags.isNotEmpty) {
      // Prepare images that satisfy the search words
      queryResult = await _isarHelper.getImagesByTags(searchTags);
      dev.log(queryResult.toString());
    } else {
      // Prepare all images
      queryResult = await _isarHelper.getAllImages();
    }

    // Update only when the queryResult is different to prevent
    // infinite update
    if (imageData.length != queryResult.length) {
      // Query result different size
      setState(() => imageData = queryResult);
      dev.log(
          "Updating TagRef Masonry Fragment. Reason: Result size different.");

      return true;
    }

    // Query result same size, compare content
    for (int i = 0; i < queryResult.length; i++) {
      if (queryResult[i].id != imageData[i].id) {
        setState(() => imageData = queryResult);
        dev.log(
            "Updating TagRef Masonry Fragment. Reason: Result content different.");

        return true;
      }
    }

    dev.log("View not updated");
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: desktopColorDarker,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.pixels >=
                  scrollNotification.metrics.maxScrollExtent - 500) {
                // set isUpdating to false to prevent calling setState
                // more than once
                // isUpdating = false;

                // Loading cool-down
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    // gridMaxCounts += masonryUpdateStep;
                  });
                });
              }
              return true;
            },
            child: MasonryGridView.count(
              crossAxisCount: (Platform.isWindows || Platform.isMacOS) ? 3 : 1,
              padding: const EdgeInsets.all(20),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              // Reserve one seat for the AddButton
              itemCount: imageData.length,
              itemBuilder: (context, index) {
                return ReferenceImage(
                    srcUrl: imageData[index].srcUrl ?? imageNotFoundAltURL,
                    imgId: imageData[index].id,
                    onDeleted: () {
                      update();
                      widget.updateNotifier.update(notifierId);
                      _gApiHelper.pushDB();
                    },
                    onTagAdded: () {
                      widget.updateNotifier.update(notifierId);
                      _gApiHelper.pushDB();
                    },
                    onTap: (imgUrl) {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              opaque: false,
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0, -1.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                final tween = Tween(begin: begin, end: end);
                                final curvedAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: curve,
                                );

                                return SlideTransition(
                                  position: tween.animate(curvedAnimation),
                                  child: child,
                                );
                              },
                              pageBuilder: (context, a1, a2) =>
                                  ScaledImageViewer(
                                    isLocalImage: true,
                                    imageUrl: imgUrl,
                                  )));
                    },
                    onTagRemoved: () {
                      dev.log("TagRefMasonryFragment onTagRemoved");
                      widget.updateNotifier.update(notifierId);
                      _gApiHelper.pushDB();
                    });
              },
            ),
          ),
          Visibility(
            visible: searchTags.isEmpty && imageData.isEmpty,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 200,
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}

class TwitterMasonryFragment extends StatefulWidget {
  const TwitterMasonryFragment({Key? key}) : super(key: key);

  @override
  State<TwitterMasonryFragment> createState() => _TwitterMasonryFragmentState();
}

class _TwitterMasonryFragmentState extends State<TwitterMasonryFragment> {
  late final GoogleApiHelper? googleApiHelper;
  final IsarHelper _isarHelper = IsarHelper();

  final List<String> keywordList = [];
  late CancelableOperation _cancelableLoadImage;

  final masonryUpdateStep = 100;

  /// Environment variables
  int gridMaxCounts = 100;
  int currentGridCount = 0;
  final List<Widget> masonryGrids = [];

  /// Upload FAB is dynamically updated with this variable
  bool syncing = false;

  /// Indicates if masonry grid view is updating
  bool canUpdate = true;

  Map<String, String> queryResult = {};

  late TwitterAPIHelper twitterHelper;

  @override
  void initState() {
    super.initState();
    queryResult = {};

    _isarHelper.openDB();

    // Authorize twitter
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      TwitterAPIDesktopHelper.getAuthClient().then((api) async {
        if (api != null) {
          twitterHelper = TwitterAPIDesktopHelper(
              api, (await api.usersService.lookupMe()).data.id);

          loadImages();
        }
      });
    } else if (Platform.isIOS || Platform.isAndroid) {
    } else {}
  }

  Future<void> loadImages() async {

    dev.log("TwitterMasonryFragment loadImages()");
    try {
      queryResult.addAll(await twitterHelper.lookupHomeTimelineImages());

      // Limit gridMaxCounts to prevent overflow
      // (gridMaxCounts > number of all images in the database)
      gridMaxCounts = min(gridMaxCounts, queryResult.entries.length);

      // Go through each record from the query result and creates an
      // TwitterImageDisplay widget which delegates the image for the record

      // Only creates 50 widgets per setState()
      if (!mounted) return;
      setState(() {
        for (currentGridCount;
        currentGridCount < gridMaxCounts;
        currentGridCount++) {
          masonryGrids.add(TwitterImage(
            onAdd: (srcUrl) {
              try {
                // _isarHelper.putImage(srcUrl, googleApiHelper: googleApiHelper);
                _isarHelper.putImage(srcUrl);

                setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      tr("twitter-image-added"),
                    ),
                    backgroundColor: Colors.blue,
                    duration: const Duration(milliseconds: 1000),
                  ));
                });
              } catch (e){
                setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      tr("twitter-image-add-fail-clicking-too-fast"),
                    ),
                    backgroundColor: Colors.redAccent,
                    duration: const Duration(milliseconds: 1000),
                  ));
                });
              }
            },
            onTap: (id, imgUrl) {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      opaque: false,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0, -1.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        final tween = Tween(begin: begin, end: end);
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: curve,
                        );

                        return SlideTransition(
                          position: tween.animate(curvedAnimation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, a1, a2) =>
                          ScaledImageViewer(
                            isLocalImage: false,
                            srcUrl: "https://twitter.com/i/web/status/$id",
                            imageUrl: imgUrl,
                          )));
            },
            tweetSrcId: queryResult.entries
                .elementAt(currentGridCount)
                .key,
            srcImgUrl: queryResult.entries
                .elementAt(currentGridCount)
                .value,
          ));
        }

        // Re-enable update when loading is done
        if (masonryGrids.length == gridMaxCounts) {
          canUpdate = true;
        }
      });
    } catch (e) {
      if (e is TwitterException) {
        if (e.body?[0][0] == "0") {
          dev.log("End has reached, no new tweets at the moment");
        }
      } else {
        dev.log(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only update when masonryGrids does not contain all images
    if (masonryGrids.length < gridMaxCounts) {
      loadImages();
    }

    // Calculates the padding from the application window width
    double paddingH = 20;

    return Container(
      color: desktopColorDarker,
      child: Stack(
        children: [
          Visibility(
              visible: currentGridCount == 0,
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 200,
                  ),
                ),
              )
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.pixels >=
                      scrollNotification.metrics.maxScrollExtent - 500 &&
                  canUpdate) {
                // set isUpdating to false to prevent calling setState
                // more than once
                canUpdate = false;

                // Loading cool-down
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    gridMaxCounts += masonryUpdateStep;
                  });
                });
              }
              return true;
            },
            child: MasonryGridView.count(
              controller: ScrollController(),
              crossAxisCount: (Platform.isWindows || Platform.isMacOS) ? 3 : 1,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: paddingH.w),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              // Reserve one seat for the AddButton
              itemCount: currentGridCount,
              itemBuilder: (context, index) {
                return masonryGrids[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}
