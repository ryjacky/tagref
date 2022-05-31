import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

class FaIconButton extends StatelessWidget {
  final IconData faIcon;
  final Size size;

  const FaIconButton(
      {Key? key,
      required this.onPressed,
      required this.faIcon,
      this.size = const Size(42, 42)})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      constraints: BoxConstraints.tight(size),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius)),
      elevation: 0,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.only(left: 1,),
        child: Center(
          child: FaIcon(
            faIcon,
            color: Colors.white,
            size: min(size.width/2, size.height/2),
          ),
        ),
      )
    );
  }
}
