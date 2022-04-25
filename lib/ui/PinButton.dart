import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

typedef VoidCallback = Function(bool unPinned);

class PinButton extends StatefulWidget {
  const PinButton({Key? key, required this.onPressed}) : super(key: key);
  final VoidCallback onPressed;

  @override
  _PinButtonState createState() => _PinButtonState();
}

class _PinButtonState extends State<PinButton> {
  bool _unPinned = true;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius)),
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      fillColor: Colors.grey.shade300.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child:
          _unPinned
              ? const RotationTransition(
                  turns: AlwaysStoppedAnimation(30 / 360),
                  child: FaIcon(
                    FontAwesomeIcons.thumbtack,
                    color: Colors.white,
                    size: 21,
                  ),
                )
              : const FaIcon(
                  FontAwesomeIcons.thumbtack,
                  color: Colors.white,
                  size: 21,
                )
      ),
      onPressed: (){
        setState(() {
          _unPinned = !_unPinned;
          widget.onPressed(_unPinned);
        });
      },

    );
  }
}