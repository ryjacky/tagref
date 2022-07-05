import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/DBHelper.dart';
import 'package:tagref/ui/FaIconButton.dart';
import 'package:tagref/ui/PinButton.dart';
import 'package:tagref/ui/TagInputField.dart';
import 'package:url_launcher/url_launcher.dart';

import '../assets/constant.dart';

typedef VoidCallback = Function();

class TwitterImageDisplay extends StatefulWidget {
  final String srcUrl;
  final int imgId;
  final int srcId;

  final VoidCallback onDeleted;

  const TwitterImageDisplay(
      {Key? key,
      required this.srcUrl,
      required this.imgId,
      required this.onDeleted,
      required this.srcId})
      : super(key: key);

  @override
  State<TwitterImageDisplay> createState() => _TwitterImageDisplayState();
}

class _TwitterImageDisplayState extends State<TwitterImageDisplay> {
  bool hovered = false;
  static const double padding = 4;

  void _launchUrl(Uri url) async {
    if (!await launchUrl(url)) print('Could not launch $url');
  }

  Future<void> removeImageFromDB(int imgId) async {
    await DBHelper.db.rawDelete('DELETE FROM images WHERE img_id = ?', [imgId]);
    widget.onDeleted();
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
                ColorFiltered(
                  colorFilter:
                      ColorFilter.mode(
                          hovered ? Colors.black12 : Colors.transparent, BlendMode.darken),
                  child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                          tileMode: TileMode.decal,
                          sigmaX: hovered ? 2 : 0,
                          sigmaY: hovered ? 2 : 0),
                      child: widget.srcId == 1
                          ? Image.network(
                              widget.srcUrl,
                              fit: BoxFit.fill,
                            )
                          : Image.file(
                              File(widget.srcUrl),
                              fit: BoxFit.fill,
                            )),
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
