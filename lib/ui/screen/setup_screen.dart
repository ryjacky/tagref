import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/helpers/TwitterAPIDesktopHelper.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/isar/IsarHelper.dart';
import 'package:tagref/ui/components/buttons.dart';

import 'home_screen_desktop.dart';

class SetupScreen extends StatefulWidget {
  final GoogleApiHelper gApiHelper;
  final IsarHelper isarHelper;
  final SharedPreferences pref;

  const SetupScreen(
      {Key? key,
      required this.gApiHelper,
      required this.isarHelper,
      required this.pref})
      : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<bool> isSelected = [false, false];

  final PageController _pageController = PageController();

  bool gDriveStatusOn = false;
  bool twitterStatusOn = false;

  @override
  void initState() {
    super.initState();
    const FlutterSecureStorage().deleteAll();
  }

  @override
  Widget build(BuildContext context) {
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
              // Page 1
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
                        // Language toggle button logic
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

              // Page 2
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
                        child: Row()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: Text(tr("integrations"),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: IntegrationDisplayButton(
                            driveLogoSrc: "assets/images/gdrive_logo.svg",
                            driveName: tr("gdrive"),
                            statusOn: gDriveStatusOn,
                            onTap: () async {
                              await widget.gApiHelper.connectGDrive();

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
                          child: IntegrationDisplayButton(
                            driveLogoSrc: "assets/images/twitter_logo.svg",
                            driveName: tr("twitter-link"),
                            statusOn: twitterStatusOn,
                            onTap: () async {
                              // Authorize twitter
                              if (Platform.isMacOS ||
                                  Platform.isWindows ||
                                  Platform.isLinux) {
                                if ((await TwitterAPIDesktopHelper
                                        .getAuthClient()) !=
                                    null) {
                                  setState(() => twitterStatusOn = true);
                                }
                              } else if (Platform.isIOS || Platform.isAndroid) {
                              } else {}
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
                          widget.pref.setBool(Preferences.initialized, true);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Platform.isMacOS || Platform.isWindows
                                          ? HomeScreen()
                                          : const Text("data")));
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

// /// Closes the current database connection, update the source db file to match
// /// remote version, and re-open the database connection
// Future<void> _compareRemoteDB() async {
//   int version = await widget.gApiHelper.compareDB();
//
//   if (version != 404) {
//     // Ask for which version to keep
//     showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//               backgroundColor: desktopColorDark,
//               title: Text(
//                 tr("is-remote-replace-local"),
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               actions: [
//                 TextButton(
//                     onPressed: () {
//                       widget.gApiHelper.pullAndReplaceLocalDB();
//                       Navigator.pop(context);
//                     },
//                     child: Text(tr("yes"))),
//                 TextButton(
//                     onPressed: () {
//                       widget.gApiHelper.pushDB();
//                       Navigator.pop(context);
//                     },
//                     child: Text(tr("no"))),
//               ],
//             ),
//         barrierDismissible: false);
//   }
// }
}
