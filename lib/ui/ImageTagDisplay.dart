import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tagref/assets/DBHelper.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/ui/TagLabel.dart';

class ImageTagDisplay extends StatefulWidget {
  final int imgId;
  const ImageTagDisplay({Key? key, required this.imgId}) : super(key: key);

  @override
  State<ImageTagDisplay> createState() => _ImageTagDisplayState();
}

class _ImageTagDisplayState extends State<ImageTagDisplay> {
  var doSomething;

  int gridMaxCounts = 0;
  int currentGridCount = 0;
  final gridUpdateStep = 50;
  final List<Widget> grids = [];
  bool isUpdating = true;

  Future<void> removeTag(String tagName) async {
    await DBHelper.db.rawDelete(
        "DELETE FROM image_tag WHERE tag_id = (SELECT tag_id FROM tags WHERE name = ?)",
        [tagName]);
  }

  Future<void> loadTags(int imgId) async {
    List<String> tags = await DBHelper.db.rawQuery(
        "SELECT name FROM tags WHERE tag_id = (SELECT tag_id FROM image_tag WHERE img_id = ?) ORDER BY name DESC",
        [imgId]);
    gridMaxCounts = max(gridMaxCounts, tags.length);
    setState(() {
      for (currentGridCount = 0;
          currentGridCount < gridMaxCounts;
          currentGridCount++) {
        String tagName = tags[currentGridCount].toString();
        late TagLabel rid;
        grids.add(rid = TagLabel(
            onPressed: () {
              setState(() {
                grids.remove(rid);
                currentGridCount -= 1;
                removeTag(tagName);
              });
            },
            tagWd: tagName));
      }
      if (grids.length == gridMaxCounts) {
        isUpdating = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (grids.length < gridMaxCounts) {
      loadTags(widget.imgId);
    }
    return Container(
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
                  gridMaxCounts += gridUpdateStep;
                });
              });
            }
            return true;
          },
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 10,
            reverse: true,
          )),
      color: Colors.grey.shade400.withOpacity(0.5),
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(cornerRadius))),
      padding: const EdgeInsets.all(12),
    );
  }
}
