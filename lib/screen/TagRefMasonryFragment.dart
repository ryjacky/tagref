import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tagref/helpers/GoogleApiHelper.dart';
import 'package:tagref/helpers/TwitterApiHelper.dart';

import '../assets/DBHelper.dart';
import '../assets/constant.dart';
import '../ui/AddButton.dart';
import '../ui/ReferenceImageDisplay.dart';
import '../ui/TagSearchBar.dart';
import 'TwitterMasonryFragment.dart';
import 'SettingScreen.dart';

class TagRefMasonryFragment extends StatefulWidget {
  const TagRefMasonryFragment({Key? key}) : super(key: key);

  @override
  State<TagRefMasonryFragment> createState() => _TagRefMasonryFragmentState();
}

class _TagRefMasonryFragmentState extends State<TagRefMasonryFragment> {
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

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      for (var path in result.paths) {
        DBHelper.db.rawInsert(""
            "INSERT INTO images (src_url, src_id) VALUES ('$path', 2)");
      }
      setState(() {
        _resetEnv();
      });
    } else {
      // TODO: User canceled the picker
    }
  }

  Future<void> loadImages() async {
    late List<Map<String, Object?>> queryResult;
       queryResult = await DBHelper.db
          .rawQuery("SELECT * FROM images ORDER BY img_id DESC;");

    // Limit gridMaxCounts to prevent overflow
    // (gridMaxCounts > number of all images in the database)
    gridMaxCounts = min(gridMaxCounts, queryResult.length);

    // Go through each record from the query result and creates an
    // ReferenceImageDisplay widget which delegates the image for the record

    // Only creates 50 widgets per setState()
    setState(() {
      for (currentGridCount;
          currentGridCount < gridMaxCounts;
          currentGridCount++) {
        late ReferenceImageDisplay rid;
        masonryGrids.add(rid = ReferenceImageDisplay(
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
    // TODO: Use .w function
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
          padding:
          EdgeInsets.symmetric(vertical: 20, horizontal: paddingH.w),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          // Reserve one seat for the AddButton
          itemCount: currentGridCount + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return AddButton(
                  onPressed: () {
                    pickFile();
                  },
                  imgUrl:
                  "https://picsum.photos/seed/${DateTime.now().day}/1000/1000");
            }
            return masonryGrids[index - 1];
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
