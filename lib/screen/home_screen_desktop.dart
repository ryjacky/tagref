import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/helpers/twitter_api_helper.dart';
import 'package:tagref/screen/setting_screen.dart';

import '../assets/constant.dart';
import '../ui/tag_search_bar.dart';
import 'tagref_masonry_fragment.dart';
import 'twitter_masonry_fragment.dart';

enum Fragments { twitterMasonry, tagrefMasonry, preferences }

class HomeScreenDesktop extends StatefulWidget {
  final GoogleApiHelper gApiHelper;

  const HomeScreenDesktop({Key? key, required this.gApiHelper})
      : super(key: key);

  @override
  State<HomeScreenDesktop> createState() => _HomeScreenDesktopState();
}

class _HomeScreenDesktopState extends State<HomeScreenDesktop>
    with SingleTickerProviderStateMixin {
  /// Upload FAB is dynamically updated with this variable
  bool syncing = false;
  bool syncingFailed = false;

  Fragments currentFragment = Fragments.tagrefMasonry;

  late final TwitterMasonryFragment tmf;
  late final TwitterApiHelper _twitterApiHelper;

  GlobalKey<TagRefMasonryFragmentState> trmfKey = GlobalKey();
  late final TagRefMasonryFragment trmf;

  final secureStorage = const FlutterSecureStorage();

  // Setting Fragment transition related animation
  late final AnimationController _slideController;

  late final Animation<Offset> _bodyOffset;

  @override
  void initState() {
    // secureStorage.deleteAll();
    super.initState();

    _slideController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);

    _bodyOffset = Tween<Offset>(
            begin: const Offset(1, 0), end: const Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _twitterApiHelper =
        TwitterApiHelper(context: context, secureStorage: secureStorage);
    trmf = TagRefMasonryFragment(
      key: trmfKey,
      gApiHelper: widget.gApiHelper,
    );

    tmf = TwitterMasonryFragment(
      twitterHelper: _twitterApiHelper,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: desktopColorDarker,
        body: Row(
          children: [
            NavigationPanel(
              onSearchChanged: (List<String> tags) =>
                  trmfKey.currentState?.setFilterTags(tags),
              onSettingClicked: () {
                setState(() {
                  if (currentFragment != Fragments.preferences) {
                    _slideController.reverse().whenComplete(() {
                      setState(() => currentFragment = Fragments.preferences);

                      _slideController.reset();
                      _slideController.forward();
                    });
                  } else {
                    _slideController.reverse().whenComplete(() {
                      setState(() => currentFragment = Fragments.tagrefMasonry);
                    });
                  }
                });
              },
              onSyncButtonClicked: () async {
                syncing = true;
                // Sync database

                bool success = await widget.gApiHelper.syncDB();

                setState(() {
                  if (success) {
                    syncing = false;
                  } else {
                    syncing = false;
                    syncingFailed = true;
                    Future.delayed(const Duration(seconds: 3))
                        .then((value) => syncingFailed = false);
                  }
                });
              },
              onTwitterClicked: () async {
                if (currentFragment != Fragments.twitterMasonry) {
                  if (!_twitterApiHelper.authorized) {
                    bool success = await _twitterApiHelper.authTwitter();

                    // try again
                    if (!success) await _twitterApiHelper.authTwitter();
                  }
                }

                if (currentFragment != Fragments.twitterMasonry) {
                  _slideController.reverse().whenComplete(() {
                    setState(() => currentFragment = Fragments.twitterMasonry);

                    _slideController.reset();
                    _slideController.forward();
                  });
                } else {
                  _slideController.reverse().whenComplete(() {
                    setState(() => currentFragment = Fragments.tagrefMasonry);
                  });
                }
              },
              syncButtonVisibility: true,
            ),

            // Body
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
                  Stack(
                    children: [
                      SizedBox(
                        height: 1.sh * 0.95,
                        child: trmf,
                      ),
                      SlideTransition(
                        position: _bodyOffset,
                        child: SizedBox(
                          height: 1.sh * 0.95,
                          child: getFragment(),
                        ),
                      )
                    ],
                  )
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
        return SettingFragment(gApiHelper: widget.gApiHelper, twitterApiHelper: _twitterApiHelper,);
      default:
        return Container();
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

typedef OnSearchChanged = Function(List<String> tags);

class NavigationPanel extends StatefulWidget {
  final OnSearchChanged onSearchChanged;

  final OnButtonClicked onSettingClicked;
  final OnButtonClicked onSyncButtonClicked;
  final OnButtonClicked onTwitterClicked;
  final bool syncButtonVisibility;

  const NavigationPanel(
      {Key? key,
      required this.onSearchChanged,
      required this.onSettingClicked,
      required this.onSyncButtonClicked,
      required this.onTwitterClicked,
      required this.syncButtonVisibility})
      : super(key: key);

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  final List<String> _tagFilterList = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        child: Container(
            color: desktopColorDark,
            child: Column(
              children: [
                WindowTitleBarBox(child: MoveWindow()),

                // App title
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "TagRef",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: TagSearchBarDesktop(
                      hintText: tr("search-hint"),
                      onSubmitted: (val) {
                        if (val.isNotEmpty && !_tagFilterList.contains(val)) {
                          setState(() => _tagFilterList.add(val));
                        }
                        widget.onSearchChanged(_tagFilterList);
                      }),
                ),

                // "Filters" label
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tr("filters"),
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )),

                // Box storing all tags that are searched by user
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: TagSearchBarKeywordsViewDesktop(
                      tagList: _tagFilterList,
                      onKeywordRemoved: (val) {
                        if (_tagFilterList.contains(val)) {
                          setState(() => _tagFilterList.remove(val));
                        }
                        widget.onSearchChanged(_tagFilterList);
                      }),
                ),

                // "All Tags" label
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tr("all-tags"),
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )),

                // Box storing all tags that are searched by user
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: AllTagsView(
                      onTagRemoved: (val) {
                        if (_tagFilterList.contains(val)) {
                          setState(() => _tagFilterList.remove(val));
                        }
                        widget.onSearchChanged(_tagFilterList);
                      }),
                ),

                // Spacer
                Expanded(child: Container()),

                NavigationPanelBottomNavigation(
                  onSettingClicked: widget.onSettingClicked,
                  onSyncButtonClicked: widget.onSyncButtonClicked,
                  onTwitterClicked: widget.onTwitterClicked,
                  syncButtonVisibility: widget.syncButtonVisibility,
                )
              ],
            )));
  }
}

typedef OnButtonClicked = Function();

class NavigationPanelBottomNavigation extends StatefulWidget {
  final OnButtonClicked onSettingClicked;
  final OnButtonClicked onSyncButtonClicked;
  final OnButtonClicked onTwitterClicked;
  final bool syncButtonVisibility;

  const NavigationPanelBottomNavigation(
      {Key? key,
      required this.onSettingClicked,
      required this.onSyncButtonClicked,
      required this.onTwitterClicked,
      required this.syncButtonVisibility})
      : super(key: key);

  @override
  State<NavigationPanelBottomNavigation> createState() =>
      _NavigationPanelBottomNavigationState();
}

class _NavigationPanelBottomNavigationState
    extends State<NavigationPanelBottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        children: [
          IconButton(
              icon: const FaIcon(FontAwesomeIcons.gear),
              color: Colors.white,
              alignment: Alignment.centerRight,
              iconSize: 28,
              onPressed: widget.onSettingClicked),
          Expanded(child: Container()),
          Visibility(
            visible: widget.syncButtonVisibility,
            // visible: currentFragment == Fragments.tagrefMasonry,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: desktopColorDarker),
              onPressed: widget.onSyncButtonClicked,
              label: Text(tr("sync")),
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
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
              onPressed: widget.onTwitterClicked),
        ],
      ),
    );
  }
}
