import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/ui/ToggleSwitch.dart';

import '../assets/constant.dart';
import '../ui/DriveStatusDisplay.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool statusOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container()),
              const Text("Preferences",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColorDark,
                      fontSize: 24)),
              Expanded(child: Container()),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.xmark),
                color: primaryColorDark,
                alignment: Alignment.center,
                iconSize: 28,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Linked Drives",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: fontColorDark)),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: DriveStatusDisplay(driveLogoSrc: "assets/images/gdrive_logo.svg", driveName: "Google Drive",),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: DriveStatusDisplay(driveLogoSrc: "assets/images/gdrive_logo.svg", driveName: "iCloud",),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: DriveStatusDisplay(driveLogoSrc: "assets/images/gdrive_logo.svg", driveName: "Dropbox",),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: Text("Manage Tags",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: fontColorDark)),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("AutoTag",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: fontColorDark)),
                          Text(
                              "AutoTag enables the tag suggestion function, which automatically add tags to your images.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18,
                                  color: fontColorDark)),
                        ],
                      ),
                      Expanded(child: Container(),),
                      const Center(
                        child: ToggleSwitch(),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }
}
