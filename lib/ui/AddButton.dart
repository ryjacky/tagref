import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/ui/FaIconButton.dart';

class AddButton extends StatelessWidget {
  final String imgUrl;

  const AddButton({Key? key, required this.onPressed, required this.imgUrl})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ImageFiltered(
              // Stronger blur (than ReferenceImageDisplay) for differentiation
              // (visually)
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Image.network(
                imgUrl,
                color: Colors.grey.shade800,
                colorBlendMode: BlendMode.screen,
              ),
            ),
            FaIconButton(onPressed: (){onPressed();}, faIcon: FontAwesomeIcons.plus, size: const Size(65, 65),)
          ],
        ));
  }
}
