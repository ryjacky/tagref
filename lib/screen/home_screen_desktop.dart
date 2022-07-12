import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/helpers/twitter_api_helper.dart';
import 'package:tagref/screen/setting_screen.dart';

import '../assets/db_helper.dart';
import '../assets/constant.dart';
import '../ui/tag_search_bar.dart';
import 'tagref_masonry_fragment.dart';
import 'twitter_masonry_fragment.dart';

enum Fragments { twitterMasonry, tagrefMasonry, preferences }

class HomeScreenDesktop extends StatefulWidget {
  const HomeScreenDesktop({Key? key}) : super(key: key);

  @override
  State<HomeScreenDesktop> createState() => _HomeScreenDesktopState();
}

class _HomeScreenDesktopState extends State<HomeScreenDesktop> {
  final List<String> tagFilterList = [];

  /// Upload FAB is dynamically updated with this variable
  bool syncing = false;
  bool syncingFailed = false;

  Fragments currentFragment = Fragments.tagrefMasonry;

  late final TwitterMasonryFragment tmf;
  late final TwitterApiHelper _twitterApiHelper;

  GlobalKey<TagRefMasonryFragmentState> trmfKey = GlobalKey();
  late final TagRefMasonryFragment trmf;

  final secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    // secureStorage.deleteAll();
    _twitterApiHelper =
        TwitterApiHelper(context: context, secureStorage: secureStorage);
    trmf = TagRefMasonryFragment(
      key: trmfKey,
    );

    tmf = TwitterMasonryFragment(
      twitterHelper: _twitterApiHelper,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculates the padding from the application window width
    // double paddingH = MediaQuery.of(context).size.width / 10;

    return Scaffold(
        backgroundColor: desktopColorDarker,
        body: Row(
          children: [
            SizedBox(
                width: 300,
                child: Container(
                    color: desktopColorDark,
                    child: Column(
                      children: [
                        WindowTitleBarBox(child: MoveWindow()),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "TagRef",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: TagSearchBarDesktop(
                              hintText: tr("search-hint"),
                              onSubmitted: (val) {
                                setState(() {
                                  if (val.isNotEmpty &&
                                      !tagFilterList.contains(val)) {
                                    tagFilterList.add(val);
                                  }

                                  trmfKey.currentState
                                      ?.filterImages(tagFilterList);
                                });
                              }),
                        ),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 10, 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Filters",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                          child: TagSearchBarKeywordsViewDesktop(
                              keywordList: tagFilterList,
                              onKeywordRemoved: (keywordRemoved) {
                                tagFilterList.remove(keywordRemoved);
                                trmfKey.currentState
                                    ?.filterImages(tagFilterList);
                              }),
                        ),
                        Expanded(child: Container()),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.gear),
                                color: Colors.white,
                                alignment: Alignment.centerRight,
                                iconSize: 28,
                                onPressed: () {
                                  setState(() {
                                    if (currentFragment !=
                                        Fragments.preferences) {
                                      currentFragment = Fragments.preferences;
                                    } else {
                                      currentFragment = Fragments.tagrefMasonry;
                                    }
                                  });
                                },
                              ),
                              Expanded(child: Container()),
                              SizedBox(
                                child: Visibility(
                                  visible: currentFragment ==
                                      Fragments.tagrefMasonry,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(20),
                                        backgroundColor: syncingFailed
                                            ? Colors.red
                                            : syncing
                                                ? Colors.orangeAccent
                                                : desktopColorDarker),
                                    onPressed: () async {
                                      pushDB(
                                              (await getApplicationSupportDirectory())
                                                  .path,
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
                                                      Future.delayed(
                                                              const Duration(
                                                                  seconds: 3))
                                                          .then((value) =>
                                                              syncingFailed =
                                                                  false);
                                                    })
                                                  }
                                              });
                                      setState(() {
                                        syncing = true;
                                      });
                                    },
                                    label: Text(tr("sync")),
                                    icon: const FaIcon(
                                        FontAwesomeIcons.arrowsRotate),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const FaIcon(
                                  FontAwesomeIcons.twitter,
                                  color: Colors.white,
                                ),
                                iconSize: 28,
                                padding: const EdgeInsets.all(20),
                                splashRadius: 1,
                                onPressed: () async {
                                  if (currentFragment !=
                                      Fragments.twitterMasonry) {
                                    if (!_twitterApiHelper.authorized) {
                                      await _twitterApiHelper.authTwitter();
                                    }
                                  }

                                  setState(() {
                                    switch (currentFragment) {
                                      case Fragments.twitterMasonry:
                                        {
                                          currentFragment =
                                              Fragments.tagrefMasonry;
                                        }
                                        break;
                                      default:
                                        {
                                          currentFragment =
                                              Fragments.twitterMasonry;
                                        }
                                        break;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ))),
            Expanded(
              child: Column(
                children: [
                  WindowTitleBarBox(
                    child: Row(
                      children: [
                        Expanded(child: MoveWindow()),
                        const WindowButtons()
                      ],
                    ),
                  ),
                  getFragment(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget getFragment() {
    switch (currentFragment) {
      case Fragments.twitterMasonry:
        return tmf;
      case Fragments.preferences:
        return const SettingFragment();
      default:
        return trmf;
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(),
        MaximizeWindowButton(),
        CloseWindowButton(),
      ],
    );
  }
}
