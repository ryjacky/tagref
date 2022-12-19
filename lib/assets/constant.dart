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

const Color desktopColorDark = Color.fromRGBO(34, 28, 68, 1);
const Color desktopColorDarker = Color.fromRGBO(15, 11, 33, 1);
const Color desktopColorLight = Color.fromRGBO(114, 105, 255, 1);

// OAuth secrets
const String twitterClientId = "emVVNlIxSDdnOWlnNzI2bTJUdVE6MTpjaQ";
const String twitterClientSecret =
    "DUFbAjOMGIDq57gZ54nGw1N4IwIJhHRHARxY5T0d_LWbwVwXty";
const String twitterCallback = "http://localhost:56738";

const String imageNotFoundAltURL = "https://img.freepik.com/free-vector/oops-404-error-with-broken-robot-concept-illustration_114360-1932.jpg?w=2000";

// Secure storage key
const String gAccessCredential = "gAccessCredential";

// Shared Preferences key
const String gDriveConnected = "gDriveConnected";

List<String> locale = ["en", "ja"];

class Preferences {
  static const language = "language";
  static const initialized = "initialized";
}

class FontSize{

  static double l1 = 72;
  static double l2 = 56;
  static double l3 = 32;
  static double l4 = 22;
  static double l5 = 12;
  static double l6 = 22;

  static double body1 = 28;
  static double body2 = 22;
}