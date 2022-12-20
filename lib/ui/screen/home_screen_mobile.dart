import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tagref/helpers/UpdateNotifier.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/ui/fragments/masonry_fragments.dart';
import 'package:tagref/ui/screen/setting_screen.dart';
import 'package:tagref/ui/screen/setting_screen_mobile.dart';

enum Fragments { twitterMasonry, tagrefMasonry, preferences }

typedef OnButtonClicked = Function();
typedef OnSearchChanged = Function(List<String> tags);

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({Key? key}) : super(key: key);

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile>
    with SingleTickerProviderStateMixin {
  Fragments currentFragment = Fragments.tagrefMasonry;

  GlobalKey<TagRefMasonryFragmentState> trmfKey = GlobalKey();
  late final TagRefMasonryFragment trmf;

  final secureStorage = const FlutterSecureStorage();
  final UpdateNotifier _updateNotifier = UpdateNotifier();

  // Setting/TwitterMasonry Fragment transition related animation
  late final AnimationController _slideController;
  late final Animation<Offset> _bodyOffset;

  late final GoogleApiHelper _gApiHelper;
  final String _notifierId = "HomeScreenMobile";

  bool tagListChanged = false;

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();

    // _gApiHelper = GoogleApiHelper(localDBPath: localDBPath, dbFileName: dbFileName, secureStorage: secureStorage)

    _slideController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _bodyOffset = Tween<Offset>(
            begin: const Offset(1, 0), end: const Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    trmf = TagRefMasonryFragment(
      key: trmfKey,
      updateNotifier: _updateNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      backgroundColor: Theme.of(context).primaryColor,
      screens: [
        TagRefMasonryFragment(updateNotifier: _updateNotifier),
        const TwitterMasonryFragment(),
        const SettingFragmentMobile(),
      ],
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,

      items: [
        PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.house_fill),
          title: tr("home"),
          activeColorPrimary: CupertinoColors.activeBlue,
          inactiveColorPrimary: CupertinoColors.systemGrey.withOpacity(0.6),
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(FontAwesomeIcons.twitter),
          title: tr("twitter"),
          activeColorPrimary: CupertinoColors.activeBlue,
          inactiveColorPrimary: CupertinoColors.systemGrey.withOpacity(0.6),
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(FontAwesomeIcons.gear),
          title: tr("settings"),
          activeColorPrimary: CupertinoColors.activeBlue,
          inactiveColorPrimary: CupertinoColors.systemGrey.withOpacity(0.6),
        ),
      ],
      confineInSafeArea: true,
      handleAndroidBackButtonPress: true,
      // Default is true.
      resizeToAvoidBottomInset: true,
      // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true,
      // Default is true.
      hideNavigationBarWhenKeyboardShows: true,
      // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Theme.of(context).primaryColor,
      ),
      itemAnimationProperties: const ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style9, // Choose the nav bar style with this property.
    );
  }

  /// Determines which fragment (setting/twitter) the user
  /// is switching to, when the user is switching back to
  /// tagref (main) fragment, returns an empty Container
  Widget getFragment() {
    switch (currentFragment) {
      case Fragments.twitterMasonry:
        return const TwitterMasonryFragment(
            // googleApiHelper: widget.gApiHelper, isarHelper: widget.isarHelper,
            );
      case Fragments.preferences:
        return const SettingFragment(
            // gApiHelper: widget.gApiHelper,
            );
      default:
        return Container();
    }
  }
}
