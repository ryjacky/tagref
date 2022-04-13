import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

class TagLabel extends StatelessWidget {
  late final String tagWd;

  TagLabel({Key? key, required this.onPressed, required this.tagWd})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.purple,
      //TODO: Make the width of TagLabel "wrap content" - auto adjust the width itself
      constraints: BoxConstraints.tight(Size(84, 33)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cornerRadius)),
      elevation: 0.1,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Row(
        children: <Widget>[
          const Spacer(),
          Text(
            tagWd,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const FaIcon(
            FontAwesomeIcons.xmark,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(
            width: 8,
          )
        ],
      ),
    );
  }
}
