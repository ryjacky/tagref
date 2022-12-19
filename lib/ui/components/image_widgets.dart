import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/isar/IsarHelper.dart';
import 'package:tagref/isar/TagRefSchema.dart';
import 'package:tagref/ui/components/tag_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:async/async.dart';

import '../../assets/constant.dart';
import 'buttons.dart';

typedef VoidCallback = Function();
typedef OnTapCallback = Function(String url);
typedef OnTwitterTapCallback = Function(String id, String url);
typedef OnTagAdded = Function(String tag);
typedef OnTwitterAddCallback = Function(String imgUrl);

// TODO: Move out functions, this class should only contain widget related codes
class ReferenceImage extends StatefulWidget {
  final String srcUrl;
  final int imgId;

  final VoidCallback onDeleted;
  final VoidCallback onTagRemoved;
  final VoidCallback onTagAdded;
  final OnTapCallback onTap;

  const ReferenceImage(
      {Key? key,
      required this.srcUrl,
      required this.imgId,
      required this.onDeleted,
      required this.onTap,
      required this.onTagAdded,
      required this.onTagRemoved})
      : super(key: key);

  @override
  State<ReferenceImage> createState() => _ReferenceImageState();
}

class _ReferenceImageState extends State<ReferenceImage> {
  final IsarHelper _isarHelper = IsarHelper();
  bool hovered = false;
  static const double padding = 4;

  List<String> tagList = [];

  late CancelableOperation _cancelableUpdateTagList;

  @override
  void initState() {
    super.initState();

    _isarHelper.openDB();
  }

  void addTagToImage(String tag) async {
    setState(() {
      if (!tagList.contains(tag)) {
        tagList.add(tag);
      }
    });

    _isarHelper.addTagToImage(widget.imgId, tag);

    widget.onTagAdded();
    updateTagList();
  }

  Future<void> removeTag(String tagWd) async {
    setState(() {
      if (tagList.contains(tagWd)) {
        tagList.remove(tagWd);
      }
    });

    await _isarHelper.removeTagFromImage(widget.imgId, tagWd);

    widget.onTagRemoved();
  }

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url)) log('Could not launch $url');
  }

  Future<void> removeImageFromDB(int imgId) async {
    await _isarHelper.deleteImage(imgId);

    widget.onDeleted();
  }

  void updateTagList() {
    _cancelableUpdateTagList = CancelableOperation.fromFuture(
      _isarHelper.getImageData(widget.imgId)
    );

    _cancelableUpdateTagList.then((databaseTags) {
      // Triggering setState in case tagList update completes after initial build
      if (databaseTags == null) return;
      databaseTags = databaseTags as ImageData;
      if (tagList.length != databaseTags.tagLinks.length) {
        tagList.clear();
        setState(() {
          for (int i = 0; i < databaseTags.tagLinks.length; i++) {
            tagList.add(databaseTags.tagLinks.elementAt(i).tagName);
          }
        });
      } else {
        for (int x = 0; x < tagList.length; x++) {
          if (tagList[x] != databaseTags.tagLinks.elementAt(x).tagName) {
            tagList.clear();
            setState(() {
              for (int i = 0; i < databaseTags.length; i++) {
                tagList.add(databaseTags.tagLinks.elementAt(i).tagName);
              }
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _cancelableUpdateTagList.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateTagList();

    Image imageWidget;

    bool imageDeleted = false;
    String fallbackImageURL =
        "https://raw.githubusercontent.com/tagref/tagref.github.io/main/images/fallback.png";

    imageWidget = widget.srcUrl.startsWith("http")
        ? Image.network(
            widget.srcUrl,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              imageDeleted = true;
              return Image.network(fallbackImageURL);
            },
          )
        : Image.file(
            File(widget.srcUrl),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              imageDeleted = true;
              return Image.network(fallbackImageURL);
            },
          );

    return InkWell(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: 350, maxHeight: 350),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      hovered ? Colors.black54 : Colors.transparent,
                      BlendMode.darken),
                  child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                          tileMode: TileMode.decal,
                          sigmaX: hovered ? 5 : 0,
                          sigmaY: hovered ? 5 : 0),
                      child: imageWidget),
                ),
              ),
              Visibility(
                visible: hovered,
                child: Padding(
                  // Extra padding for image overlay
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(padding),
                            child: FaIconButton(
                                faIcon: FontAwesomeIcons.trash,
                                onPressed: () {
                                  removeImageFromDB(widget.imgId);
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(padding),
                            child: FaIconButton(
                                faIcon: FontAwesomeIcons.link,
                                onPressed: () {
                                  _launchUrl(Uri.parse(widget.srcUrl));
                                }),
                          ),
                          // TODO: TOBE implemented
                          // Padding(
                          //   padding: const EdgeInsets.all(padding),
                          //   child: FaIconButton(
                          //       faIcon: FontAwesomeIcons.magnifyingGlass,
                          //       onPressed: () {}),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.all(padding),
                          //   child: PinButton(onPressed: (pinned) {}),
                          // ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(padding),
                        child: TagInputField(
                            hintText: tr("add-tag-field-hint"),
                            onSubmitted: addTagToImage),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(padding),
                        child: TagListBox(
                          height: 185,
                          tagList: tagList,
                          onTagDeleted: removeTag,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () => widget.onTap(imageDeleted ? fallbackImageURL : widget.srcUrl),
        onHover: (val) {
          setState(() {
            // Controls overlay visibility
            hovered = val;
            updateTagList();
          });
        });
  }
}

class TwitterImage extends StatefulWidget {
  final String srcImgUrl;
  final String tweetSrcId;

  final OnTwitterTapCallback onTap;
  final OnTwitterAddCallback onAdd;

  const TwitterImage(
      {Key? key,
      required this.srcImgUrl,
      required this.tweetSrcId,
      required this.onTap,
      required this.onAdd})
      : super(key: key);

  @override
  State<TwitterImage> createState() => _TwitterImageState();
}

class _TwitterImageState extends State<TwitterImage> {
  bool hovered = false;
  static const double padding = 4;

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url)) log('Could not launch $url');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      hovered ? Colors.black12 : Colors.transparent,
                      BlendMode.darken),
                  child: SizedBox(
                    height: 300,
                    child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                            tileMode: TileMode.decal,
                            sigmaX: hovered ? 2 : 0,
                            sigmaY: hovered ? 2 : 0),
                        child: Image.network(
                          widget.srcImgUrl,
                          fit: BoxFit.cover,
                        )),
                  )),
              Visibility(
                visible: hovered,
                child: Padding(
                  // Extra padding for image overlay
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(padding),
                            child: FaIconButton(
                                faIcon: FontAwesomeIcons.link,
                                onPressed: () {
                                  _launchUrl(Uri.parse(
                                      "https://twitter.com/i/web/status/${widget.tweetSrcId}"));
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(padding),
                            child: FaIconButton(
                                faIcon: FontAwesomeIcons.plus,
                                onPressed: () =>
                                    widget.onAdd(widget.srcImgUrl)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () => widget.onTap(widget.tweetSrcId, widget.srcImgUrl),
        onHover: (val) {
          setState(() {
            // Controls overlay visibility
            hovered = val;
          });
        });
  }
}
