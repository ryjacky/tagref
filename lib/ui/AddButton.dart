import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

class AddButton extends StatelessWidget {
  const AddButton({Key? key, required this.onPressed}) : super(key: key);
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: MaterialButton(
        onPressed: onPressed,
        color: Colors.grey.shade200.withOpacity(0.5),
        splashColor: Colors.grey.shade500.withOpacity(0.5),
        elevation: 0.1,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: const Padding(
            padding: EdgeInsets.all(30.0),
            child: FaIcon(
              FontAwesomeIcons.plus,
              color: Colors.white,
              size: buttonHeight,
            )),
      ),
    );
  }
}
