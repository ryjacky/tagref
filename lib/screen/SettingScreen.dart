import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagref/assets/FontSize.dart';
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
              Text(tr("pref"),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColorDark,
                      fontSize: FontSize.l3.sp)),
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
              Text(tr("linked-drives"),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.l3.sp,
                      color: fontColorDark)),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: DriveStatusDisplay(driveLogoSrc: "assets/images/gdrive_logo.svg", driveName: tr("gdrive"),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DriveStatusDisplay(driveLogoSrc: "assets/images/gdrive_logo.svg", driveName: tr("icloud"),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DriveStatusDisplay(driveLogoSrc: "assets/images/gdrive_logo.svg", driveName: tr("dropbox"),),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: Text(tr("manage-tags"),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.l3.sp,
                        color: fontColorDark)),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr("auto-tag"),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSize.l3.sp,
                                  color: fontColorDark)),
                          Text(
                              tr("auto-tag-desc"),
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: FontSize.body2.sp,
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
