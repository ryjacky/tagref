import 'dart:developer' as dev;
import 'dart:math';

import 'package:async/async.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/helpers/UpdateNotifier.dart';
import 'package:tagref/isar/IsarHelper.dart';
import 'package:tagref/ui/components/tag_widgets.dart';
import 'package:tagref/ui/screen/home_screen_desktop.dart';

class NavigationPanel extends StatefulWidget {
  final OnButtonClicked onSettingClicked;
  final OnButtonClicked onSyncButtonClicked;
  final OnButtonClicked onTwitterClicked;
  final bool syncButtonVisibility;

  final UpdateNotifier updateNotifier;

  NavigationPanel(
      {Key? key,
      required this.onSettingClicked,
      required this.onSyncButtonClicked,
      required this.onTwitterClicked,
      required this.syncButtonVisibility,
      required this.updateNotifier})
      : super(key: key);

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  final IsarHelper _isarHelper = IsarHelper();
  final List<String> _tagFilterList = [];

  final List<String> fullTagList = [];
  late CancelableOperation cancellableDBQuery;

  final String notifierId = "NavigationPanel";

  @override
  void initState() {
    super.initState();

    widget.updateNotifier.addOnUpdateListener((callerId, type, data) {
      if (callerId == notifierId) return;

      updateTagList();
    });

    _isarHelper.openDB().then((value) => updateTagList());
  }

  void updateTagList() {
    dev.log("NavigationPanel updateTagList()");
    cancellableDBQuery = CancelableOperation.fromFuture(
      _isarHelper.getAllTags(true),
    );

    cancellableDBQuery.then((results) {
      bool tagListChanged = false;
      List<String> newTagList = [];
      for (var node in results) {
        newTagList.add(node.tagName as String);
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
  void dispose() {
    cancellableDBQuery.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        width: min(0.35.sw, 300),
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
                          widget.updateNotifier.update(notifierId,
                              type: UpdateType.searchChanged,
                              data: _tagFilterList);
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
                          widget.updateNotifier.update(notifierId,
                              type: UpdateType.searchChanged,
                              data: _tagFilterList);
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
                      onTagDeleted: (tagName) async {
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
                                          _isarHelper.deleteTag(tagName);
                                          updateTagList();
                                          widget.updateNotifier
                                              .update(notifierId);

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
              syncButtonVisibility:
                  // _gApiHelper.isInitialized &&
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
