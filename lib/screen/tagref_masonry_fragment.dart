import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/screen/home_screen_desktop.dart';

import '../assets/constant.dart';
import '../assets/db_helper.dart';
import '../ui/reference_image_display.dart';

class TagRefMasonryFragment extends StatefulWidget {
  final GoogleApiHelper gApiHelper;

  const TagRefMasonryFragment({Key? key, required this.gApiHelper})
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
        DBHelper.db.rawInsert(
            "INSERT INTO images (src_url, src_id) VALUES (?, 2)", [path]);
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
          "SELECT * FROM images WHERE img_id IN (SELECT DISTINCT img_id FROM image_tag INNER JOIN tags on image_tag.tag_id = tags.tag_id WHERE tags.name IN ($inString)) ORDER BY img_id DESC;";
      queryResult = await DBHelper.db.rawQuery(queryImages, filterTags);
    } else {
      String queryImages = "SELECT * FROM images ORDER BY img_id DESC;";

      queryResult = await DBHelper.db.rawQuery(queryImages);
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
                                imageUrl: imgUrl,
                              )));
                },
                srcId: rawImageInfo[index]["src_id"] as int);
          },
        ),
      ),
    );
  }
}
