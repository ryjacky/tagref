import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:isar/isar.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/isar/IsarHelper.dart';
import 'package:tagref/ui/components/buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class ScaledImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? srcUrl;
  final bool isLocalImage;

  const ScaledImageViewer(
      {Key? key,
        required this.imageUrl,
        required this.isLocalImage, this.srcUrl})
      : super(key: key);

  @override
  State<ScaledImageViewer> createState() => _ScaledImageViewerState();
}

class _ScaledImageViewerState extends State<ScaledImageViewer> {
  final IsarHelper _isarHelper = IsarHelper();
  late final GoogleApiHelper googleApiHelper;

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
                                  _isarHelper.putImage(widget.imageUrl,
                                      googleApiHelper: googleApiHelper);

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
