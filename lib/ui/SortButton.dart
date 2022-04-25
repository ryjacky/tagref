import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/constant.dart';

///Sort-Button.
class SortBtn extends StatelessWidget {
  //TODO: use_key_in_widget_constructors
  const SortBtn({required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(buttonWidth, buttonHeight)),
      elevation: 0.1,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: FaIcon(
          FontAwesomeIcons.arrowDownShortWide,
          color: Colors.purple,
          size: 18,
        ),
      ),
    );
  }
}
