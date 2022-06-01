import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/constant.dart';

class ToggleSwitch extends StatefulWidget {
  const ToggleSwitch({Key? key}) : super(key: key);

  @override
  State<ToggleSwitch> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<ToggleSwitch> {
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      width: 70.0,
      height: 40.0,
      valueFontSize: 25.0,
      toggleSize: 30.0,
      value: enabled,
      inactiveTextFontWeight: FontWeight.w400,
      activeTextFontWeight: FontWeight.w400,
      borderRadius: 25,
      activeIcon: const FaIcon(FontAwesomeIcons.check, color: primaryColorDark,),
      padding: 6.0,
      activeColor: primaryColorDark,
      showOnOff: false,
      onToggle: (val) {
        setState(() {
          enabled = val;
        });
      },
    );
  }
}
