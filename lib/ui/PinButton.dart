import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../assets/constant.dart';

/// Pin-Button.
class PinButton extends StatefulWidget {
  const PinButton({Key? key, required this.onPressed}) : super(key: key);
  final GestureTapCallback onPressed;

  @override
  _PinButtonState createState() => _PinButtonState();
}

class _PinButtonState extends State<PinButton> {
  bool _unPinned = true;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        onPressed: _togglePin,
        constraints:
            BoxConstraints.tight(const Size(buttonWidth, buttonHeight)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius)),
        elevation: 0.1,
        fillColor: Colors.grey.shade200.withOpacity(0.5),
        splashColor: Colors.grey.shade500.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: (_unPinned
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
                )),
        ));
  }

  void _togglePin() {
    setState(() {
      if (_unPinned) {
        _unPinned = false;
      } else {
        _unPinned = true;
      }
    });
  }
}
