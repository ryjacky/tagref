import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tagref/helpers/GoogleApiHelper.dart';
import 'package:tagref/helpers/TwitterApiHelper.dart';

import '../assets/DBHelper.dart';
import '../assets/constant.dart';
import '../ui/TagSearchBar.dart';
import 'SettingScreen.dart';
import 'TagRefMasonryFragment.dart';
import 'TwitterMasonryFragment.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> keywordList = [];

  /// Upload FAB is dynamically updated with this variable
  bool syncing = false;
  bool syncingFailed = false;

  bool twitterModeOn = false;

  final TwitterMasonryFragment tmf = const TwitterMasonryFragment();
  final TagRefMasonryFragment trmf = const TagRefMasonryFragment();

  @override
  Widget build(BuildContext context) {
    // Calculates the padding from the application window width
    // double paddingH = MediaQuery.of(context).size.width / 10;

    return Scaffold(
        floatingActionButton: Visibility(
          visible: !twitterModeOn,
          child: FloatingActionButton.extended(
            backgroundColor: syncingFailed
                ? Colors.red
                : syncing
                    ? Colors.orangeAccent
                    : primaryColorDark,
            onPressed: () async {
              pushDB((await getApplicationSupportDirectory()).path,
                      DBHelper.dbFileName)
                  .then((success) => {
                        if (success)
                          {
                            setState(() {
                              syncing = false;
                            })
                          }
                        else
                          {
                            setState(() {
                              syncing = false;
                              syncingFailed = true;
                              Future.delayed(const Duration(seconds: 3))
                                  .then((value) => syncingFailed = false);
                            })
                          }
                      });
              setState(() {
                syncing = true;
              });
            },
            label: Text(tr("sync")),
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
          ),
        ),
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
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.twitter,
                  color: Colors.white,
                ),
                iconSize: 28,
                padding: const EdgeInsets.all(20),
                splashRadius: 1,
                onPressed: () {
                  setState(() {
                    twitterModeOn = !twitterModeOn;
                  });
                  if (Platform.isAndroid || Platform.isIOS) {
                    // TwitterApiHelper().authTwitterMobile();
                  }
                },
              ),
              Expanded(child: Container()),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.bars),
                alignment: Alignment.centerRight,
                iconSize: 28,
                onPressed: () {
                  Navigator.push(
                          context,
                          PageRouteBuilder(
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                              pageBuilder: (context, a1, a2) =>
                                  const SettingScreen()))
                      .then((remoteChanged) => setState(() {
                            // Refreshes home page when local db is updated from source/
                            //TODO CHANGE THIS IN TAGREFMASONRYFRAGMENT

                            // remoteChanged ? _resetEnv() : "";
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
            twitterModeOn ? tmf : trmf,
          ],
        ));
  }
}
