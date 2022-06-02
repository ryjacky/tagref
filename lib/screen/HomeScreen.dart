import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';
import '../ui/AddButton.dart';
import '../ui/TagSearchBar.dart';
import 'SettingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> keywordList = [];

  @override
  Widget build(BuildContext context) {
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
              TagSearchBar(onSubmitted: (val){
                setState(() {
                  keywordList.add(val);
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
            TagSearchBarKeywordsView(keywordList: keywordList,),
            Expanded(
              child: MasonryGridView.count(
                crossAxisCount: 3,
                padding: EdgeInsets.fromLTRB(paddingH, 20, paddingH, 0),
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                itemCount: 100,
                itemBuilder: (context, index) {
                  return AddButton(
                    onPressed: () {},
                    imgUrl:
                    "https://images.unsplash.com/photo-1453728013993-6d66e9c9123a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dmlld3xlbnwwfHwwfHw%3D&w=1000&q=80",
                  );
                },
              ),
            )
          ],
        ));
  }
}
