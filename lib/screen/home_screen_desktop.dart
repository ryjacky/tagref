import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime/mime.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/helpers/twitter_api_helper.dart';
import 'package:tagref/screen/setting_screen.dart';
import 'package:tagref/ui/buttons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../assets/constant.dart';
import '../assets/db_helper.dart';
import '../ui/tag_widgets.dart';
import '../fragments/masonry_fragments.dart';
import 'package:async/async.dart';

enum Fragments { twitterMasonry, tagrefMasonry, preferences }

typedef OnButtonClicked = Function();
typedef OnSearchChanged = Function(List<String> tags);

class HomeScreen extends StatefulWidget {
  final GoogleApiHelper gApiHelper;

  const HomeScreen({Key? key, required this.gApiHelper}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Fragments currentFragment = Fragments.tagrefMasonry;

  late final TwitterApiHelper _twitterApiHelper;

  GlobalKey<TagRefMasonryFragmentState> trmfKey = GlobalKey();
  late final TagRefMasonryFragment trmf;

  final secureStorage = const FlutterSecureStorage();

  // Setting/TwitterMasonry Fragment transition related animation
  late final AnimationController _slideController;
  late final Animation<Offset> _bodyOffset;

  bool tagListChanged = false;

  @override
  void initState() {
    // secureStorage.delete(key: "com.tagref.twitterUserToken");
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
      onTagListChanged: () => setState(() => tagListChanged = true),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    DBHelper.rawInsertAndPush(
                        "INSERT INTO images (src_url, src_id) VALUES (?, ?)",
                        [file.path, Platform.localHostname],
                        googleApiHelper: widget.gApiHelper);
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
          (Platform.isMacOS || Platform.isWindows)
              ? homeScreenDesktopBody()
              : homeScreenMobileBody()
        ]));
  }

  Widget homeScreenMobileBody() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
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
        )
      ],
    );
  }

  Widget homeScreenDesktopBody() {
    return Row(
      children: [
        NavigationPanel(
          gApiHelper: widget.gApiHelper,
          tagListChanged: tagListChanged,
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
            // Sync database
            bool success = await widget.gApiHelper.updateLocalDB(true);

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
              if (!_twitterApiHelper.authorized ||
                  _twitterApiHelper.expires
                      .compareTo(DateTime.now())
                      .isNegative) {
                bool success = await _twitterApiHelper.authTwitter();

                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      tr("twitter-link-failed"),
                    ),
                    backgroundColor: Colors.redAccent,
                    duration: const Duration(milliseconds: 1500),
                  ));
                  return;
                }
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
          syncButtonVisibility:
              currentFragment == Fragments.tagrefMasonry ? true : false,
        ),

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
    );
  }

  /// Determines which fragment (setting/twitter) the user
  /// is switching to, when the user is switching back to
  /// tagref (main) fragment, returns an empty Container
  Widget getFragment() {
    switch (currentFragment) {
      case Fragments.twitterMasonry:
        return TwitterMasonryFragment(
          twitterHelper: _twitterApiHelper,
          googleApiHelper: widget.gApiHelper,
        );
      case Fragments.preferences:
        return SettingFragment(
          gApiHelper: widget.gApiHelper,
          twitterApiHelper: _twitterApiHelper,
        );
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
        CloseWindowButton(
          onPressed: () => appWindow.hide(),
        ),
      ],
    );
  }
}

class NavigationPanel extends StatefulWidget {
  final OnSearchChanged onSearchChanged;

  final OnButtonClicked onSettingClicked;
  final OnButtonClicked onSyncButtonClicked;
  final OnButtonClicked onTwitterClicked;
  final bool syncButtonVisibility;

  final GoogleApiHelper gApiHelper;

  bool tagListChanged;

  NavigationPanel(
      {Key? key,
      required this.onSearchChanged,
      required this.onSettingClicked,
      required this.onSyncButtonClicked,
      required this.onTwitterClicked,
      required this.syncButtonVisibility,
      required this.tagListChanged,
      required this.gApiHelper})
      : super(key: key);

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  final List<String> _tagFilterList = [];

  final List<String> fullTagList = [];
  late CancelableOperation cancellableDBQuery;

  void updateFullTagList() {
    String queryTag = "SELECT name FROM tags";
    cancellableDBQuery = CancelableOperation.fromFuture(
      db.rawQuery(queryTag),
    );

    cancellableDBQuery.then((results) {
      bool tagListChanged = false;
      List<String> newTagList = [];
      for (var row in results) {
        newTagList.add(row["name"] as String);
      }

      if (newTagList.length != fullTagList.length) {
        tagListChanged = true;
      } else {
        for (int i = 0; i < newTagList.length; i++) {
          if (newTagList[i] != fullTagList[i]) tagListChanged = true;
        }
      }

      if (tagListChanged) {
        fullTagList.clear();
        setState(() {
          fullTagList.addAll(newTagList);
          tagListChanged = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    updateFullTagList();
  }

  @override
  void dispose() {
    cancellableDBQuery.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tagListChanged == true) {
      updateFullTagList();
      widget.tagListChanged = false;
    }
    return Container(
        width: math.min(0.35.sw, 300),
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
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            SizedBox(
              height: 0.7.sh,
              child: ListView(
                controller: ScrollController(),
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: SearchBarDesktop(
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
                    child: TagListBox(
                        height: 130,
                        color: desktopColorDarker,
                        tagList: _tagFilterList,
                        onTagDeleted: (val) {
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

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: TagListBox(
                      color: desktopColorDarker,
                      height: 230,
                      onTagDeleted: (val) async {
                        int tagId = (await db.rawQuery(
                            'SELECT tag_id FROM tags WHERE name=?;',
                            [val]))[0]["tag_id"];

                        // Confirm delete tag
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  backgroundColor: desktopColorDark,
                                  title: Text(
                                    tr("confirm-delete-tag"),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          await DBHelper.rawDeleteAndPush(
                                              'DELETE FROM image_tag WHERE tag_id = ?',
                                              [tagId],
                                              googleApiHelper:
                                                  widget.gApiHelper);
                                          await DBHelper.rawDeleteAndPush(
                                              'DELETE FROM tags WHERE tag_id = ?',
                                              [tagId],
                                              googleApiHelper:
                                                  widget.gApiHelper);
                                          updateFullTagList();

                                          Navigator.pop(context);
                                        },
                                        child: Text(tr("yes"))),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(tr("no"))),
                                  ],
                                ),
                            barrierDismissible: false);
                      },
                      tagList: fullTagList,
                    ),
                  ),
                ],
              ),
            ),

            // App title

            // Spacer
            Expanded(child: Container()),

            NavigationPanelBottomNavigation(
              onSettingClicked: widget.onSettingClicked,
              onSyncButtonClicked: widget.onSyncButtonClicked,
              onTwitterClicked: widget.onTwitterClicked,
              syncButtonVisibility: widget.gApiHelper.isInitialized &&
                  widget.syncButtonVisibility,
            )
          ],
        ));
  }
}

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
              label: Text(tr("update")),
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

class ScaledImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? srcUrl;
  final GoogleApiHelper? googleApiHelper;
  final bool isLocalImage;

  const ScaledImageViewer(
      {Key? key,
      required this.imageUrl,
      required this.googleApiHelper,
      required this.isLocalImage, this.srcUrl})
      : super(key: key);

  @override
  State<ScaledImageViewer> createState() => _ScaledImageViewerState();
}

class _ScaledImageViewerState extends State<ScaledImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(1, 1, 1, 0.5),
        body: Stack(
          children: [
            SizedBox.expand(
              child: InteractiveViewer(
                maxScale: 10,
                child: widget.imageUrl.contains("http")
                    ? Image.network(widget.imageUrl)
                    : Image.file(File(widget.imageUrl)),
              ),
            ),
            Column(
              children: [
                Expanded(child: Container()),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: const Color.fromRGBO(0, 0, 0, 0.5),
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      Visibility(
                          visible: !widget.isLocalImage,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: FaIconButton(
                                onPressed: () {
                                  DBHelper.insertImage(widget.imageUrl, true,
                                      googleApiHelper: widget.googleApiHelper);

                                  setState(() {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        tr("twitter-image-added"),
                                      ),
                                      backgroundColor: Colors.blue,
                                      duration:
                                          const Duration(milliseconds: 1000),
                                    ));
                                  });
                                },
                                faIcon: FontAwesomeIcons.plus),
                          )),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: FaIconButton(
                            faIcon: FontAwesomeIcons.link,
                            onPressed: () {
                              launchUrl(Uri.parse(widget.srcUrl ?? widget.imageUrl));
                            }),
                      ),
                      FaTextButton(
                        onPressed: () => Navigator.pop(context),
                        faIcon: FontAwesomeIcons.xmark,
                        text: Text(
                          tr("close"),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }
}
