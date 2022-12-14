import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/screen/home_screen_desktop.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

import '../assets/constant.dart';
import '../assets/db_helper.dart';
import '../helpers/twitter_api_helper.dart';
import '../ui/image_widgets.dart';

typedef OnTagListChanged = Function();

class TagRefMasonryFragment extends StatefulWidget {
  final GoogleApiHelper gApiHelper;
  final OnTagListChanged onTagListChanged;

  const TagRefMasonryFragment(
      {Key? key, required this.gApiHelper, required this.onTagListChanged})
      : super(key: key);

  @override
  State<TagRefMasonryFragment> createState() => TagRefMasonryFragmentState();
}

class TagRefMasonryFragmentState extends State<TagRefMasonryFragment> {
  List<String> filterTags = [];

  List<Map<String, Object?>> rawImageInfo = [];

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
        DBHelper.rawInsertAndPush(
            "INSERT INTO images (src_url, src_id) VALUES (?, 2)", [path],
            googleApiHelper: widget.gApiHelper);
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
    late List<Map<String, Object?>> queryResult;

    if (filterTags.isNotEmpty) {
      String inString = "";
      for (int i = 0; i < filterTags.length; i++) {
        inString += i == filterTags.length - 1 ? "?" : "?,";
      }

      String queryImages =
          "SELECT * FROM images WHERE src_id in (?, ?) AND img_id IN (SELECT DISTINCT img_id FROM image_tag INNER JOIN tags on image_tag.tag_id = tags.tag_id WHERE tags.name IN ($inString)) ORDER BY img_id DESC;";

      List options = ["1", Platform.localHostname];
      options.addAll(filterTags);
      queryResult = await db.rawQuery(queryImages, options);
    } else {
      String queryImages =
          "SELECT * FROM images WHERE src_id in (?, ?) ORDER BY img_id DESC;";

      queryResult =
          await db.rawQuery(queryImages, ["1", Platform.localHostname]);
    }

    if (queryResult.length != rawImageInfo.length) {
      setState(() => rawImageInfo = queryResult);
      return true;
    } else {
      for (int i = 0; i < rawImageInfo.length; i++) {
        if (rawImageInfo[i]["img_id"] != queryResult[i]["img_id"]) {
          setState(() => rawImageInfo = queryResult);

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
          itemCount: rawImageInfo.length,
          itemBuilder: (context, index) {
            return ReferenceImage(
              srcUrl: rawImageInfo[index]["src_url"] as String,
              imgId: rawImageInfo[index]["img_id"] as int,
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
                              imageUrl: imgUrl,
                            )));
              },
              srcId: rawImageInfo[index]["src_id"] as String,
              onTagRemoved: () {
                widget.gApiHelper.pushDB();
              },
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

  const TwitterMasonryFragment(
      {Key? key, required this.twitterHelper, this.googleApiHelper})
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
            DBHelper.insertImage(srcUrl, true,
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
                          imageUrl: imgUrl,
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
