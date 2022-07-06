import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tagref/helpers/GoogleApiHelper.dart';
import 'package:tagref/helpers/TwitterApiHelper.dart';

import '../ui/TwitterImageDisplay.dart';

class TwitterMasonryFragment extends StatefulWidget {
  final TwitterApiHelper twitterHelper;

  const TwitterMasonryFragment({Key? key, required this.twitterHelper}) : super(key: key);

  @override
  State<TwitterMasonryFragment> createState() => _TwitterMasonryFragmentState();
}

class _TwitterMasonryFragmentState extends State<TwitterMasonryFragment> {
  final List<String> keywordList = [];

  final masonryUpdateStep = 50;

  /// Environment variables
  int gridMaxCounts = 50;
  int currentGridCount = 0;
  final List<Widget> masonryGrids = [];

  /// Upload FAB is dynamically updated with this variable
  bool syncing = false;

  /// Indicates if masonry grid view is updating
  bool isUpdating = true;

  List<Map<String, Object?>> queryResult = [];
  late List<String> imageUrls = [];

  Future<void> loadImages() async {
    late List<String> tempImageUrls;

    for (int i = 0; i <= 3; i++) {
      if (i == 3) {
        print("something went wrong, please try again");
        return;
      }

      try {
        tempImageUrls = await widget.twitterHelper.lookupHomeTimelineImages();
        break;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    for (int i = 0; i < tempImageUrls.length; i++) {
      var gridElement = {"src_id": 1, "img_id": 0, "src_url": tempImageUrls[i]};
      if (!imageUrls.contains(tempImageUrls[i])) {
        imageUrls.add(tempImageUrls[i]);
        queryResult.add(gridElement);
      }
    }

    // Limit gridMaxCounts to prevent overflow
    // (gridMaxCounts > number of all images in the database)
    gridMaxCounts = min(gridMaxCounts, queryResult.length);

    // Go through each record from the query result and creates an
    // TwitterImageDisplay widget which delegates the image for the record

    // Only creates 50 widgets per setState()
    setState(() {
      for (currentGridCount;
          currentGridCount < gridMaxCounts;
          currentGridCount++) {
        late TwitterImageDisplay rid;
        masonryGrids.add(rid = TwitterImageDisplay(
          onDeleted: () {
            setState(() {
              masonryGrids.remove(rid);
              currentGridCount -= 1;
            });
          },
          srcId: queryResult[currentGridCount]["src_id"] as int,
          imgId: queryResult[currentGridCount]["img_id"] as int,
          srcUrl: queryResult[currentGridCount]["src_url"].toString(),
        ));
      }

      // Re-enable update when loading is done
      if (masonryGrids.length == gridMaxCounts) {
        isUpdating = true;
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
    double paddingH = MediaQuery.of(context).size.width / 10;

    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels >=
                  scrollNotification.metrics.maxScrollExtent - 500 &&
              isUpdating) {
            // set isUpdating to false to prevent calling setState
            // more than once
            isUpdating = false;

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

  /// Reset masonry view environment variables
  void _resetEnv() {
    currentGridCount = 0;
    gridMaxCounts = 50;
    masonryGrids.clear();
  }
}
