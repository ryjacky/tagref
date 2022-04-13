import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Add-Button.
class AddButton extends StatelessWidget {
  //TODO: use_key_in_widget_constructors
  const AddButton({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.grey.shade200.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      elevation: 0.1,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: const Padding(
          padding: EdgeInsets.all(30.0),
          child: FaIcon(
            FontAwesomeIcons.plus,
            color: Colors.white,
          )),
    );
  }
}