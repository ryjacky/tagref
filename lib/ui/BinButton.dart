import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

class BinButton extends StatelessWidget {
  const BinButton({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(buttonWidth, buttonHeight)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: FaIcon(
          FontAwesomeIcons.solidTrashCan,
          color: Colors.white,
          size: 21,
        ),
      ),
    );
  }
}
