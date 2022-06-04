import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../assets/constant.dart';
class TagLabel extends StatelessWidget {
  final String tagWd;

  const TagLabel({Key? key, required this.onPressed, required this.tagWd})
      : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: RawMaterialButton(
        onPressed: onPressed,
        fillColor: primaryColorDark,
        constraints: const BoxConstraints.tightFor(height: 33),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius)),
        elevation: 0.1,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 8,
            ),
            Text(
              tagWd,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              width: 8,
            ),
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
      ),
    );
  }
}