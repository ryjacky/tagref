import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/isar/IsarHelper.dart';
import 'package:tagref/isar/TagRefSchema.dart';
import 'package:tagref/screen/home_screen_desktop.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

import '../../assets/constant.dart';
import '../../helpers/twitter_api_helper.dart';
import '../components/image_widgets.dart';

typedef OnTagListChanged = Function();

class TagRefMasonryFragment extends StatefulWidget {
  final GoogleApiHelper gApiHelper;
  final OnTagListChanged onTagListChanged;
  final IsarHelper isarHelper;

  const TagRefMasonryFragment(
      {Key? key, required this.gApiHelper, required this.onTagListChanged, required this.isarHelper})
      : super(key: key);

  @override
  State<TagRefMasonryFragment> createState() => TagRefMasonryFragmentState();
}

class TagRefMasonryFragmentState extends State<TagRefMasonryFragment> {
  List<String> filterTags = [];

  List<ImageData> imageData = [];

  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      refreshImageList();
    });
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      for (var path in result.paths) {
        if (path == null) continue;

        widget.isarHelper.putImage(path, googleApiHelper: widget.gApiHelper);
      }
    } else {
      // Do nothing when user closed the dialog
    }
  }

  void setFilterTags(List<String> tags) {
    filterTags = tags;
    refreshImageList();
  }

  Future<bool> refreshImageList() async {
    late List<ImageData> queryResult;

    if (filterTags.isNotEmpty) {
      queryResult = widget.isarHelper.getImagesByTags(filterTags);
    } else {
      queryResult = widget.isarHelper.getAllImages();
    }

    if (queryResult.length != imageData.length) {
      setState(() => imageData = queryResult);
      return true;
    } else {
      for (int i = 0; i < imageData.length; i++) {
        if (imageData[i].id != queryResult[i].id) {
          setState(() => imageData = queryResult);

          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Only update when masonryGrids does not contain all images
    // if (masonryGrids.length < gridMaxCounts) {
    //   loadImages();
    // }

    return Container(
      color: desktopColorDarker,
      child: NotificationListener<ScrollNotification>(
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
                refreshImageList();
                widget.gApiHelper.pushDB();
              },
              onTagAdded: () {
                widget.onTagListChanged();
                widget.gApiHelper.pushDB();
              },
              onTap: (imgUrl) {
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
                        pageBuilder: (context, a1, a2) => ScaledImageViewer(
                              isLocalImage: true,
                              googleApiHelper: widget.gApiHelper,
                              imageUrl: imgUrl, isarHelper: widget.isarHelper,
                            )));
              },
              onTagRemoved: () {
                widget.gApiHelper.pushDB();
              }, isarHelper: widget.isarHelper,
            );
          },
        ),
      ),
    );
  }
}

class TwitterMasonryFragment extends StatefulWidget {
  final TwitterApiHelper twitterHelper;
  final GoogleApiHelper? googleApiHelper;
  final IsarHelper isarHelper;

  const TwitterMasonryFragment(
      {Key? key, required this.twitterHelper, this.googleApiHelper, required this.isarHelper})
      : super(key: key);

  @override
  State<TwitterMasonryFragment> createState() => _TwitterMasonryFragmentState();
}

class _TwitterMasonryFragmentState extends State<TwitterMasonryFragment> {
  final List<String> keywordList = [];

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

  @override
  void initState() {
    super.initState();
    widget.twitterHelper.untilId = "";
    queryResult = {};
  }

  Future<void> loadImages() async {
    for (int i = 0; i <= 3; i++) {
      if (i == 3) {
        dev.log("something went wrong, please try again");
        canUpdate = true;
        return;
      }

      try {
        queryResult
            .addAll(await widget.twitterHelper.lookupHomeTimelineImages());
        break;
      } catch (e) {
        if (e is TwitterException) {
          if (e.body?[0][0] == "0") {
            dev.log("End has reached, no new tweets at the moment");
          }
        }

        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }

    // Limit gridMaxCounts to prevent overflow
    // (gridMaxCounts > number of all images in the database)
    gridMaxCounts = min(gridMaxCounts, queryResult.entries.length);

    // Go through each record from the query result and creates an
    // TwitterImageDisplay widget which delegates the image for the record

    // Only creates 50 widgets per setState()
    setState(() {
      for (currentGridCount;
          currentGridCount < gridMaxCounts;
          currentGridCount++) {
        masonryGrids.add(TwitterImage(
          onAdd: (srcUrl) {
            widget.isarHelper.putImage(srcUrl,
                googleApiHelper: widget.googleApiHelper);

            setState(() {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  tr("twitter-image-added"),
                ),
                backgroundColor: Colors.blue,
                duration: const Duration(milliseconds: 1000),
              ));
            });
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
                    pageBuilder: (context, a1, a2) => ScaledImageViewer(
                          isLocalImage: false,
                          srcUrl: "https://twitter.com/i/web/status/$id",
                          googleApiHelper: widget.googleApiHelper,
                          imageUrl: imgUrl, isarHelper: widget.isarHelper,
                        )));
          },
          tweetSrcId: queryResult.entries.elementAt(currentGridCount).key,
          srcImgUrl: queryResult.entries.elementAt(currentGridCount).value,
        ));
      }

      // Re-enable update when loading is done
      if (masonryGrids.length == gridMaxCounts) {
        canUpdate = true;
      }
    });
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
      child: NotificationListener<ScrollNotification>(
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
    );
  }
}
