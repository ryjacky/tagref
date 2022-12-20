import 'dart:developer';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mime/mime.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/helpers/UpdateNotifier.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/isar/IsarHelper.dart';
import 'package:tagref/ui/components/navigation_panel_desktop.dart';
import 'package:tagref/ui/components/WindowButtons.dart';
import 'package:tagref/ui/fragments/masonry_fragments.dart';
import 'package:tagref/ui/screen/setting_screen.dart';

enum Fragments { twitterMasonry, tagrefMasonry, preferences }

typedef OnButtonClicked = Function();
typedef OnSearchChanged = Function(List<String> tags);

class HomeScreenDesktop extends StatefulWidget {
  const HomeScreenDesktop({Key? key}) : super(key: key);

  @override
  State<HomeScreenDesktop> createState() => _HomeScreenDesktopState();
}

class _HomeScreenDesktopState extends State<HomeScreenDesktop>
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
  final String _notifierId = "HomeScreenDesktop";

  bool tagListChanged = false;

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
    NavigationPanelDesktop navPanel = NavigationPanelDesktop(
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
        // Sync database
        bool success = await _gApiHelper.updateLocalDB(true);

        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              tr(success ? "updated" : "update-failed"),
            ),
            backgroundColor: success ? Colors.green : Colors.redAccent,
            duration: const Duration(milliseconds: 1000),
          ));
        });
      },
      onTwitterClicked: () async {
        if (currentFragment != Fragments.twitterMasonry) {
          _slideController.reverse().whenComplete(() {
            setState(() => currentFragment = Fragments.twitterMasonry);

            _slideController.reset();
            _slideController.forward();
          });
        } else {
          _slideController.reverse().whenComplete(() {
            setState(() {
              currentFragment = Fragments.tagrefMasonry;
              _updateNotifier.update(_notifierId);
            });
          });
        }
      },
      syncButtonVisibility:
          currentFragment == Fragments.tagrefMasonry ? true : false,
      updateNotifier: _updateNotifier,
    );

    return Scaffold(
        backgroundColor: desktopColorDarker,
        body: Stack(children: [
          DropTarget(
            onDragDone: (detail) {
              setState(() {
                log("Drag Done, ${detail.files.length} files dropped, checking file format...");
                for (var file in detail.files) {
                  log("Checking file: ${file.path}");

                  var type = lookupMimeType(file.path) ?? "unknown";
                  log("Type = $type");

                  if (type.contains("image")) {
                    // widget.isarHelper.putImage(file.path,
                    //     googleApiHelper: widget.gApiHelper);
                  }
                }
              });
            },
            onDragEntered: (detail) {
              setState(() {
                log("Drag Entered");
              });
            },
            onDragExited: (detail) {
              setState(() {
                log("Drag Exited");
              });
            },
            child: SizedBox.expand(
                child: Container(
              color: Colors.transparent,
            )),
          ),
          Row(
            children: [
              navPanel,

              // TagRef/twitter/setting fragment
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
                          height: 0.92.sh,
                          child: trmf,
                        ),
                        SlideTransition(
                          position: _bodyOffset,
                          child: SizedBox(
                            height: 0.93.sh,
                            child: getFragment(),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          )
        ]));
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
        return SettingFragment(
            // gApiHelper: widget.gApiHelper,
            );
      default:
        return Container();
    }
  }
}
