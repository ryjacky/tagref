import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

class EditTagButton extends StatelessWidget {
  const EditTagButton({Key? key, required this.onPressed}) : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints:
          BoxConstraints.tight(const Size(buttonWidth * 3, buttonHeight)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius)),
      elevation: 0.1,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Spacer(),
            FaIcon(
              FontAwesomeIcons.pencil,
              color: Colors.white,
              size: 18,
            ),
            Spacer(),
            Text(
              "Edit tags",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
