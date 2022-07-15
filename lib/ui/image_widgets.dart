import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/db_helper.dart';
import 'package:tagref/ui/tag_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../assets/constant.dart';
import 'buttons.dart';

typedef VoidCallback = Function();
typedef OnTapCallback = Function(String url);

class ReferenceImage extends StatefulWidget {
  final String srcUrl;
  final int imgId;
  final int srcId;

  final VoidCallback onDeleted;
  final OnTapCallback onTap;

  const ReferenceImage(
      {Key? key,
      required this.srcUrl,
      required this.imgId,
      required this.onDeleted,
      required this.srcId, required this.onTap})
      : super(key: key);

  @override
  State<ReferenceImage> createState() => _ReferenceImageState();
}

class _ReferenceImageState extends State<ReferenceImage> {
  bool hovered = false;
  static const double padding = 4;

  List<String> tagList = [];

  @override
  void initState() {
    super.initState();
    // DBHelper.db.rawQuery(
    //     "SELECT name FROM tags WHERE tag_id IN (SELECT tag_id FROM image_tag WHERE img_id=?);",
    //     [widget.imgId]).then((existedTags) {
    //   // Triggering setState in case tagList update completes after initial build
    //   try {
    //     setState(() {
    //       for (int i = 0; i < existedTags.length; i++) {
    //         tagList.add(existedTags[i]["name"]);
    //       }
    //     });
    //   } catch (e) {
    //     log("Reference Image going out of viewport before tag is loaded");
    //   }
    // });
  }

  void addTagToImage(String tag) async {
    setState(() {
      if (!tagList.contains(tag)) {
        tagList.add(tag);
      }
    });

    String tagQuery = "SELECT * FROM tags WHERE name=?;";
    List<Map> tagExists = await DBHelper.db.rawQuery(tagQuery, [tag]);

    // Create tag (if not existed in 'tags' table) and creates
    // new record in 'image_tag' table
    late int newTagId;
    if (tagExists.isEmpty) {
      String newTagStatement = "INSERT INTO tags (name) VALUES (?);";
      newTagId = await DBHelper.db.rawInsert(newTagStatement, [tag]);
    } else {
      newTagId = tagExists.first["tag_id"];
    }

    // Creates the relation record in image_tag when it does not exists
    String imageTagQuery =
        "SELECT * FROM image_tag WHERE img_id=? AND tag_id=?;";
    List<Map> imageTagExists =
        await DBHelper.db.rawQuery(imageTagQuery, [widget.imgId, newTagId]);
    if (imageTagExists.isEmpty) {
      DBHelper.db.rawInsert(
          "INSERT INTO image_tag (img_id, tag_id) VALUES (?,?);",
          [widget.imgId, newTagId]);
    }

    updateTagList();

  }

  void removeTag(String tagWd) {
    setState(() {
      if (tagList.contains(tagWd)) {
        tagList.remove(tagWd);
      }
    });

    String deleteTagStatement =
        "DELETE FROM image_tag WHERE img_id=? AND tag_id=(SELECT tag_id FROM tags WHERE name=?);";
    DBHelper.db.rawDelete(deleteTagStatement, [widget.imgId, tagWd]);
  }

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url)) log('Could not launch $url');
  }

  Future<void> removeImageFromDB(int imgId) async {
    await DBHelper.db.rawDelete('DELETE FROM images WHERE img_id = ?', [imgId]);
    widget.onDeleted();
  }

  void updateTagList() {
    DBHelper.db.rawQuery(
        "SELECT name FROM tags WHERE tag_id IN (SELECT tag_id FROM image_tag WHERE img_id=?);",
        [widget.imgId]).then((databaseTags) {
      // Triggering setState in case tagList update completes after initial build

      if (tagList.length != databaseTags.length){
        setState(() {
          tagList = [];
          for (int i = 0; i < databaseTags.length; i++) {
            tagList.add(databaseTags[i]["name"]);
          }
        });
      } else {
        for (int x = 0; x < tagList.length; x++){
          if (tagList[x] != databaseTags[x]["name"]){
            tagList = [];

            setState(() {
              for (int i = 0; i < databaseTags.length; i++) {
                tagList.add(databaseTags[i]["name"]);
              }
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    updateTagList();
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
                      child: widget.srcId == 1
                          ? Image.network(
                              widget.srcUrl,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(widget.srcUrl),
                              fit: BoxFit.cover,
                            )),
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
                          Padding(
                            padding: const EdgeInsets.all(padding),
                            child: FaIconButton(
                                faIcon: FontAwesomeIcons.magnifyingGlass,
                                onPressed: () {}),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(padding),
                            child: PinButton(onPressed: (pinned) {}),
                          ),
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
        onTap: () => widget.onTap(widget.srcUrl),
        onHover: (val) {
          setState(() {
            // Controls overlay visibility
            hovered = val;
            updateTagList();
          });
        });
  }
}



class TwitterImageDisplay extends StatefulWidget {
  final String srcUrl;
  final int imgId;
  final int srcId;

  final VoidCallback onDeleted;
  final OnTapCallback onTap;

  const TwitterImageDisplay(
      {Key? key,
        required this.srcUrl,
        required this.imgId,
        required this.onDeleted,
        required this.srcId, required this.onTap})
      : super(key: key);

  @override
  State<TwitterImageDisplay> createState() => _TwitterImageDisplayState();
}

class _TwitterImageDisplayState extends State<TwitterImageDisplay> {
  bool hovered = false;
  static const double padding = 4;

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url)) log('Could not launch $url');
  }

  Future<void> removeImageFromDB(int imgId) async {
    await DBHelper.db.rawDelete('DELETE FROM images WHERE img_id = ?', [imgId]);
    await DBHelper.db.rawDelete('DELETE FROM image_tag WHERE img_id = ?', [imgId]);
    widget.onDeleted();
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
                  colorFilter:
                  ColorFilter.mode(
                      hovered ? Colors.black12 : Colors.transparent, BlendMode.darken),
                  child: SizedBox(
                    height: 300,
                    child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                            tileMode: TileMode.decal,
                            sigmaX: hovered ? 2 : 0,
                            sigmaY: hovered ? 2 : 0),
                        child: widget.srcId == 1
                            ? Image.network(
                          widget.srcUrl,
                          fit: BoxFit.cover,
                        )
                            : Image.file(
                          File(widget.srcUrl),
                          fit: BoxFit.cover,
                        )),
                  )
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
                                faIcon: FontAwesomeIcons.link,
                                onPressed: () {
                                  _launchUrl(Uri.parse(widget.srcUrl));
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(padding),
                            child: FaIconButton(
                                faIcon: FontAwesomeIcons.plus,
                                onPressed: () {}),
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
        onTap: () => widget.onTap(widget.srcUrl),
        onHover: (val) {
          setState(() {
            // Controls overlay visibility
            hovered = val;
          });
        });
  }
}
