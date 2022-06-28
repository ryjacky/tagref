import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/DBHelper.dart';
import 'package:tagref/ui/FaIconButton.dart';
import 'package:tagref/ui/ImageTagDisplay.dart';
import 'package:tagref/ui/PinButton.dart';
import 'package:tagref/ui/TagInputField.dart';
import 'package:url_launcher/url_launcher.dart';

import '../assets/constant.dart';

typedef VoidCallback = Function();

class ReferenceImageDisplay extends StatefulWidget {
  final String srcUrl;
  final int imgId;
  final int srcId;

  final VoidCallback onDeleted;

  const ReferenceImageDisplay(
      {Key? key,
      required this.srcUrl,
      required this.imgId,
      required this.onDeleted,
      required this.srcId})
      : super(key: key);

  @override
  State<ReferenceImageDisplay> createState() => _ReferenceImageDisplayState();
}

class _ReferenceImageDisplayState extends State<ReferenceImageDisplay> {
  bool hovered = false;
  static const double padding = 4;

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url)) print('Could not launch $url');
  }

  Future<void> removeImageFromDB(int imgId) async {
    await DBHelper.db.rawDelete('DELETE FROM images WHERE img_id = ?', [imgId]);
    widget.onDeleted();
  }

  Future<void> addNewTag(String newTag, int imgId) async {
    var tagID = await DBHelper.db
        .rawQuery("SELECT tag_id FROM tags WHERE name = ?", [newTag]);
    //check if the typed tag already exists.
    //if does not exists then add this new tag.
    if (tagID.isNull) {
      await DBHelper.db
          .rawInsert("""INSERT INTO tags (name) VALUES ('$newTag')""");
      tagID = await DBHelper.db
          .rawQuery("SELECT tag_id FROM tags WHERE name = ?", [newTag]);
    }
    //
    await DBHelper.db.rawInsert(
        """INSERT INTO image_tag (img_id, tag_id) VALUES ('$imgId', '$tagID')""");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Container(
            color: Colors.white,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                ImageFiltered(
                    imageFilter: ImageFilter.blur(
                        // Use 0.001 instead of 0 for browser compatibility
                        sigmaX: hovered ? 5 : 0.001,
                        sigmaY: hovered ? 5 : 0.001),
                    child: widget.srcId == 1
                        ? Image.network(widget.srcUrl)
                        : Image.file(File(widget.srcUrl))),
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
                              onSubmitted: (tag) {
                                setState(() {
                                  if (tag.isNotEmpty) {
                                    addNewTag(tag, widget.imgId);
                                  }
                                });
                              }),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(padding),
                            child: ImageTagDisplay(imgId: widget.imgId))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        onTap: () {},
        onHover: (val) {
          setState(() {
            // Controls overlay visibility
            hovered = val;
          });
        });
  }
}
