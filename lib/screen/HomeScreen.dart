import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/DBHelper.dart';
import '../assets/constant.dart';
import '../ui/AddButton.dart';
import '../ui/ReferenceImageDisplay.dart';
import '../ui/TagSearchBar.dart';
import 'SettingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> keywordList = [];

  int gridMaxCounts = 50;
  int currentGridCount = 0;
  final masonryUpdateStep = 50;

  final List<Widget> masonryGrids = [];

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
      // User canceled the picker
    }
  }

  Future<void> loadImages() async {
    List<Map<String, Object?>> queryResult = await DBHelper.db
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

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: 30,
                height: 30,
                alignment: Alignment.centerLeft,
              ),
              Expanded(child: Container()),
              TagSearchBar(
                  hintText: tr("search-hint"),
                  onSubmitted: (val) {
                    setState(() {
                      if (val.isNotEmpty) {
                        keywordList.add(val);
                      }
                    });
                  }),
              Expanded(child: Container()),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.bars),
                alignment: Alignment.centerRight,
                iconSize: 28,
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingScreen()))
                      .then((remoteChanged) => setState(() {
                        // Refreshes home page when local db is updated from source
                            remoteChanged ? _resetEnv() : "";
                          }));
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            TagSearchBarKeywordsView(
              keywordList: keywordList,
            ),
            Expanded(
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
                  crossAxisCount: 3,
                  padding:
                      EdgeInsets.symmetric(vertical: 20, horizontal: paddingH),
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
            )
          ],
        ));
  }

  /// Reset masonry view environment variables
  void _resetEnv() {
    currentGridCount = 0;
    gridMaxCounts = 50;
    masonryGrids.clear();
  }
}
