import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../assets/constant.dart';

class PinButtonRev2 extends StatefulWidget {
  final GestureTapCallback onPressed;
  const PinButtonRev2({Key? key, required this.onPressed}) : super(key: key);


  @override
  State<PinButtonRev2> createState() => _PinButtonRev2State();
}

class _PinButtonRev2State extends State<PinButtonRev2> {
  bool pinned = false;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(cornerRadius),
      isSelected: [ pinned ],
      renderBorder: false,
      color: Colors.grey,
      disabledColor: Colors.grey,
      splashColor: Colors.grey.shade200.withOpacity(0.5),
      fillColor: Colors.grey.shade500.withOpacity(0.5),
      children: [
        pinned
            ? const FaIcon(
          FontAwesomeIcons.thumbtack,
          color: Colors.white,
          size: 21,
        )
            : const RotationTransition(
          turns: AlwaysStoppedAnimation(30 / 360),
          child: FaIcon(
            FontAwesomeIcons.thumbtack,
            color: Colors.white,
            size: 21,
          ),
        )
      ],

      onPressed: (int index){
        setState(() {
          pinned = !pinned;
          widget.onPressed();
        });
      },
    );
  }
}
