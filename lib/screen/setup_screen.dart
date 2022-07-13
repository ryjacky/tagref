

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/helpers/twitter_api_helper.dart';
import 'package:tagref/main.dart';
import 'package:tagref/screen/home_screen.dart';
import 'package:tagref/ui/drive_status_display.dart';

import '../assets/db_helper.dart';
import '../assets/font_size.dart';
import '../ui/toggle_switch.dart';
import 'home_screen_desktop.dart';

class SetupScreen extends StatefulWidget {
  final GoogleApiHelper gApiHelper;
  const SetupScreen({Key? key, required this.gApiHelper}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<bool> isSelected = [false, false];

  final PageController _pageController = PageController();

  bool gDriveStatusOn = false;
  bool twitterStatusOn = false;

  @override
  Widget build(BuildContext context) {
    // Query for window width
    double width = MediaQuery.of(context).size.width;

    // Set current language to active in the language options toggle button
    for (int i = 0; i < context.supportedLocales.length; i++) {
      isSelected[i] = context.locale.toString() == locale[i];
    }

    return Scaffold(
        backgroundColor: desktopColorDarker,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(tr("welcome-text"),
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(tr("tag-ref-description"),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 100, 0, 20),
                    child: Text(tr("choose-lang"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    isSelected: isSelected,
                    onPressed: (index) {
                      setState(() {
                        // Implements the exclusive selection feature for
                        // the language options toggle button
                        for (int buttonIndex = 0;
                            buttonIndex < isSelected.length;
                            buttonIndex++) {
                          if (buttonIndex == index) {
                            isSelected[buttonIndex] = true;
                          } else {
                            isSelected[buttonIndex] = false;
                          }
                        }

                        context.setLocale(Locale(locale[index]));
                      });
                    },
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(cornerRadius),
                                child: SvgPicture.asset(
                                  "assets/images/us.svg",
                                  height: 60,
                                  width: 50,
                                ),
                              ),
                              Text("English",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 2,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.body1.sp)),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(cornerRadius),
                                child: SvgPicture.asset(
                                  "assets/images/jp.svg",
                                  height: 60,
                                  width: 50,
                                ),
                              ),
                              Text("日本語",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 2,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.body1.sp)),
                            ],
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20)),
                          backgroundColor:
                              MaterialStateProperty.all(desktopColorDark)),
                      child: Text(tr("next"),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 60.w, 20.w, 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr("customize-exp"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge),
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 20.w, 0, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: (width / 1.3).w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tr("auto-tag"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(tr("auto-tag-desc"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(40.w, 0, 0, 0),
                              child: const ToggleSwitch(),
                            )
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: Text(tr("integrations"),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: DriveStatusDisplay(
                            driveLogoSrc: "assets/images/gdrive_logo.svg",
                            driveName: tr("gdrive"),
                            statusOn: gDriveStatusOn,
                            onTap: () async {
                              if (!widget.gApiHelper.isInitialized) {
                                await widget.gApiHelper.authUser();
                                await widget.gApiHelper.initializeGoogleApi();
                                await _applyRemoteDBChanges();
                              }

                              // Update shared preferences
                              SharedPreferences.getInstance().then((pref) =>
                                  pref.setBool(gDriveConnected, true));

                              setState(() {
                                gDriveStatusOn = true;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: DriveStatusDisplay(
                            driveLogoSrc: "assets/images/gdrive_logo.svg",
                            driveName: tr("twitter-link"),
                            statusOn: twitterStatusOn,
                            onTap: () async {
                              if (await TwitterApiHelper(
                                      context: context,
                                      secureStorage:
                                          const FlutterSecureStorage())
                                  .authTwitter()) {
                                setState(() => twitterStatusOn = true);
                              }
                            },
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(30),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Platform.isMacOS || Platform.isWindows ? HomeScreen(
                                        gApiHelper: widget.gApiHelper,
                                      ) : HomeScreenDesktop(
                                        gApiHelper: widget.gApiHelper,
                                      )));
                        },
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(20)),
                            backgroundColor:
                                MaterialStateProperty.all(desktopColorDark)),
                        child: Text(tr("done"),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  /// Closes the current database connection, update the source db file to match
  /// remote version, and re-open the database connection
  Future<void> _applyRemoteDBChanges() async {
    await DBHelper.db.close();
    await widget.gApiHelper.pullAndReplaceLocalDB();
    await DBHelper.initializeDatabase();
  }
}
