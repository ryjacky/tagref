import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../assets/db_helper.dart';
import '../ui/add_button.dart';
import '../ui/reference_image_display.dart';

class TagRefMasonryFragment extends StatefulWidget {
  const TagRefMasonryFragment({Key? key}) : super(key: key);

  @override
  State<TagRefMasonryFragment> createState() => TagRefMasonryFragmentState();
}

class TagRefMasonryFragmentState extends State<TagRefMasonryFragment> {
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

  String filterTagString = "";

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      for (var path in result.paths) {
        DBHelper.db.rawInsert(""
            "INSERT INTO images (src_url, src_id) VALUES ('$path', 2)");
      }
      setStateAndResetEnv();
    } else {
      // Do nothing when user closed the dialog
    }
  }

  void filterImages(List<String> tags) {
    filterTagString = "";

    if (tags.isNotEmpty) {
      for (var tag in tags) {
        filterTagString += "\"$tag\",";
      }

      filterTagString =
          filterTagString.substring(0, filterTagString.length - 1);
    }

    setStateAndResetEnv();
  }

  Future<void> loadImages() async {
    String queryImages = "SELECT * FROM images ORDER BY img_id DESC;";
    if (filterTagString != "") {
      queryImages =
          "SELECT * FROM images WHERE img_id IN (SELECT DISTINCT img_id FROM image_tag INNER JOIN tags on image_tag.tag_id = tags.tag_id WHERE tags.name IN ($filterTagString)) ORDER BY img_id DESC;";
      print(queryImages);
    }

    late List<Map<String, Object?>> queryResult;
    queryResult = await DBHelper.db.rawQuery(queryImages);

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
          padding: const EdgeInsets.all(20),
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
  void setStateAndResetEnv() {
    setState(() {
      currentGridCount = 0;
      gridMaxCounts = 50;
      masonryGrids.clear();
    });
  }
}
