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
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      constraints: BoxConstraints.tight(const Size(42, 42)),
      fillColor: Colors.grey.shade300.withOpacity(0.5),
      splashColor: Colors.grey.shade500.withOpacity(0.5),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 12),
          child: _unPinned
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
      onPressed: () {
        setState(() {
          // Flips the pin state when clicked
          _unPinned = !_unPinned;

          // Triggers callback and pass the pin state
          widget.onPressed(_unPinned);
        });
      },
    );
  }
}
