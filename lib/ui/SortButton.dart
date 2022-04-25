import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/constant.dart';

///Sort-Button.
class SortBtn extends StatelessWidget {
  const SortBtn({Key? key, required this.onPressed}) : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints.tight(const Size(buttonWidth, buttonHeight)),
      elevation: 0.1,
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: FaIcon(
          FontAwesomeIcons.arrowDownShortWide,
          color: Colors.purple,
          size: 18,
        ),
      ),
    );
  }
}
