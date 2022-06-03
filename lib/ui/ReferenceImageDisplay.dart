import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/ui/FaIconButton.dart';
import 'package:tagref/ui/PinButton.dart';
import 'package:tagref/ui/TagInputField.dart';

import '../assets/constant.dart';

class ReferenceImageDisplay extends StatefulWidget {
  final String srcUrl;

  const ReferenceImageDisplay({Key? key, required this.srcUrl}) : super(key: key);

  @override
  State<ReferenceImageDisplay> createState() => _ReferenceImageDisplayState();
}

class _ReferenceImageDisplayState extends State<ReferenceImageDisplay> {
  bool hovered = false;
  static const double padding = 4;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Container(
            color: primaryColor,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      // Use 0.001 instead of 0 for browser compatibility
                        sigmaX: hovered ? 5 : 0.001, sigmaY: hovered ? 5 : 0.001),
                    child: Image.network(
                      widget.srcUrl,
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
                                  faIcon: FontAwesomeIcons.trash,
                                  onPressed: () {}),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(padding),
                              child: FaIconButton(
                                  faIcon: FontAwesomeIcons.link,
                                  onPressed: () {}),
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
                            hintText: tr("add-tag-field-hint"),),
                        )
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
