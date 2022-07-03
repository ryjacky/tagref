import 'dart:ui';

import 'package:flutter/cupertino.dart';

const double cornerRadius = 4;

const double buttonWidth = 42;
const double buttonHeight = 42;

const Color primaryColor = Color.fromRGBO(218, 191, 255, 1);
const Color accentColor = Color.fromRGBO(247, 239, 255, 1.0);
const Color primaryColorDark = Color.fromRGBO(187, 107, 217, 1);
const Color fontColorDark = Color.fromRGBO(61, 34, 71, 1);
const Color fontColorLight = Color.fromRGBO(255, 255, 255, 1);

// Secure storage key
const String gAccessCredential = "gAccessCredential";

// Shared Preferences key
const String gDriveConnected = "gDriveConnected";

List<String> locale = ["en", "ja"];

class Preferences {
  static const language = "language";
}
