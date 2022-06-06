import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
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
  int currentGridCounts = 0;
  final masonryUpdateStep = 50;

  final List<Widget> masonryGrids = [
    AddButton(
        onPressed: () {},
        imgUrl:
            "https://cdn.pixabay.com/photo/2022/05/03/23/35/rapeseed-7172836__340.jpg")
  ];

  bool isUpdating = true;

  // Loads all images into the MasonryGridView and adds an AddButton at last
  Future<void> loadMasonryGrids() async {
    List<Map<String, Object?>> queryResult =
        await DBHelper.db.rawQuery("SELECT src_url FROM images;");

    // Set the roof of gridMaxCounts to the maximum number of query result
    gridMaxCounts = min(gridMaxCounts, queryResult.length);

    // Go through each record from the query result and creates an
    // ReferenceImageDisplay widget which delegates the image for the record

    // Only creates 50 widgets per setState()
    setState(() {
      gridMaxCounts = min(gridMaxCounts, queryResult.length);

      for (currentGridCounts;
          currentGridCounts < gridMaxCounts - 1;
          currentGridCounts++) {
        masonryGrids.insert(
            1,
            ReferenceImageDisplay(
              srcUrl: queryResult[currentGridCounts]["src_url"] == null
                  ? ""
                  : queryResult[currentGridCounts]["src_url"].toString(),
            ));
      }

      if (masonryGrids.length == gridMaxCounts){
        isUpdating = true;
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    if (masonryGrids.length != gridMaxCounts) {
      loadMasonryGrids();
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
                          builder: (context) => const SettingScreen()));
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

                    // Loading cooldown
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
                  itemCount: currentGridCounts,
                  itemBuilder: (context, index) {
                    return masonryGrids[index];
                  },
                ),
              ),
            )
          ],
        ));
  }
}
