import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tagref/ui/BinButton.dart';
import 'package:tagref/ui/PinButton.dart';
import 'package:tagref/ui/SourceButtonSmall.dart';
import 'package:tagref/ui/TagInputField.dart';

import '../assets/constant.dart';

class RefImageDisplay extends StatefulWidget {
  final String srcUrl;

  const RefImageDisplay({Key? key, required this.srcUrl}) : super(key: key);

  @override
  State<RefImageDisplay> createState() => _RefImageDisplayState();
}

class _RefImageDisplayState extends State<RefImageDisplay> {
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
                        sigmaX: hovered ? 5 : 0.001, sigmaY: hovered ? 5 : 0.001),
                    child: Image.network(
                      widget.srcUrl,
                    )),
                Visibility(
                  visible: hovered,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(padding),
                              child: BinButton(onPressed: () {}),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(padding),
                              child: SourceButtonSmall(onPressed: () {}),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(padding),
                              child: PinButton(onPressed: (pinned) {}),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(padding),
                          child: TagInputField(),
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
            hovered = val;
          });
        });
  }
}
