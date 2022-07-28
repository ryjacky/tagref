import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagref/assets/db_helper.dart';
import 'package:tagref/assets/font_size.dart';
import 'package:tagref/ui/buttons.dart';
import 'package:tagref/ui/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

import '../assets/constant.dart';
import '../helpers/google_api_helper.dart';
import '../helpers/twitter_api_helper.dart';

class SettingScreen extends StatefulWidget {
  final GoogleApiHelper gApiHelper;
  final TwitterApiHelper twitterApiHelper;

  const SettingScreen(
      {Key? key, required this.gApiHelper, required this.twitterApiHelper})
      : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final secureStorage = const FlutterSecureStorage();

  /// Controls the displayed text for DriveStatusDisplay widget, shows "ON"
  /// when value is true, otherwise "OFF"
  bool twitterStatusOn = false;

  /// Controls the displayed text for DriveStatusDisplay widget, shows "ON"
  /// when value is true, otherwise "OFF"
  bool gDriveStatusOn = false;

  /// Passed when closing the preferences screen, should be set to true whenever
  /// settings regarding to any cloud drives are changed
  bool remoteChanged = false;

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((pref) => setState(() {
          gDriveStatusOn = pref.getBool(gDriveConnected) != null ? true : false;
        }));

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: primaryColor,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const IconButton(
                icon: FaIcon(FontAwesomeIcons.xmark),
                disabledColor: primaryColor,
                alignment: Alignment.center,
                iconSize: 28,
                onPressed: null,
              ),
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
                  Navigator.pop(context, remoteChanged);
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
              Text(tr("integrations"),
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
                      child: IntegrationDisplayButton(
                        driveLogoSrc: "assets/images/gdrive_logo.svg",
                        driveName: tr("gdrive"),
                        statusOn: gDriveStatusOn,
                        onTap: () async {
                          if (gDriveStatusOn) {
                            // Confirm google drive disconnection
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: Text(tr("disconnect-gdrive")),
                                      actions: [
                                        TextButton(
                                            onPressed: disconnectGDrive,
                                            child: Text(tr("yes"))),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(tr("no"))),
                                      ],
                                    ),
                                barrierDismissible: false);
                          } else {
                            // The only case when driveApi will be null should be
                            // when GDrive has never been set up before
                            if (!widget.gApiHelper.isInitialized) {
                              await widget.gApiHelper.initializeAuthClient();
                              await widget.gApiHelper.initializeGoogleApi();
                              await _applyRemoteDBChanges();
                            }

                            // Update shared preferences
                            SharedPreferences.getInstance().then(
                                (pref) => pref.setBool(gDriveConnected, true));

                            remoteChanged = true;

                            setState(() {
                              gDriveStatusOn = true;
                            });
                          }
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
                          if (!twitterStatusOn) {
                            if (await widget.twitterApiHelper.authTwitter()) {
                              setState(() => twitterStatusOn = true);
                            }
                          } else {
                            widget.twitterApiHelper.purgeData();
                          }
                        },
                      ),
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
                      Expanded(
                        child: SizedBox(
                          width: (1.sw / 1.3).w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr("auto-tag"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.l3.sp,
                                      color: fontColorDark)),
                              Text(tr("auto-tag-desc"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: FontSize.body1.sp,
                                      color: fontColorDark)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(40.w, 0, 0, 0),
                        child: const ToggleSwitch(),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }

  /// Closes the current database connection, update the source db file to match
  /// remote version, and re-open the database connection
  Future<void> _applyRemoteDBChanges() async {
    await db.close();
    await widget.gApiHelper.pullAndReplaceLocalDB();
    await DBHelper.initializeDatabase();
  }

  /// Removes all local configurations about google drive
  void disconnectGDrive() {
    SharedPreferences.getInstance().then((pref) => setState(() {
          pref.remove(gDriveConnected);
        }));
    widget.gApiHelper.isInitialized = false;
    widget.gApiHelper.purgeAccessCredentials(secureStorage);
    Navigator.pop(context);
    setState(() {
      gDriveStatusOn = true;
    });
  }
}

class SettingFragment extends StatefulWidget {
  final GoogleApiHelper gApiHelper;
  final TwitterApiHelper twitterApiHelper;

  const SettingFragment(
      {Key? key, required this.gApiHelper, required this.twitterApiHelper})
      : super(key: key);

  @override
  State<SettingFragment> createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  final secureStorage = const FlutterSecureStorage();

  /// Controls the displayed text for TwitterStatusDisplay widget, shows "ON"
  /// when value is true, otherwise "OFF"
  bool twitterStatusOn = false;

  /// Controls the displayed text for DriveStatusDisplay widget, shows "ON"
  /// when value is true, otherwise "OFF"
  bool gDriveStatusOn = false;

  /// Passed when closing the preferences screen, should be set to true whenever
  /// settings regarding to any cloud drives are changed
  bool remoteChanged = false;

  @override
  void initState() {
    super.initState();
    secureStorage
        .read(key: "com.tagref.twitterUserToken")
        .then((value) => setState(() => twitterStatusOn = value == null));
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((pref) => setState(() {
          gDriveStatusOn = pref.getBool(gDriveConnected) != null ? true : false;
        }));

    twitterStatusOn = widget.twitterApiHelper.authorized;

    return Container(
      color: desktopColorDarker,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr("pref"),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text(tr("integrations"),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: IntegrationDisplayButton(
                      driveLogoSrc: "assets/images/gdrive_logo.svg",
                      driveName: tr("gdrive"),
                      statusOn: gDriveStatusOn,
                      onTap: () async {
                        if (gDriveStatusOn) {
                          // Confirm google drive disconnection
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    backgroundColor: desktopColorDark,
                                    title: Text(
                                      tr("disconnect-gdrive"),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: disconnectGDrive,
                                          child: Text(tr("yes"))),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(tr("no"))),
                                    ],
                                  ),
                              barrierDismissible: false);
                        } else {
                          // The only case when driveApi will be null should be
                          // when GDrive has never been set up before
                          if (!widget.gApiHelper.isInitialized) {
                            await widget.gApiHelper.initializeAuthClient();
                            await widget.gApiHelper.initializeGoogleApi();
                            await _compareRemoteDB();
                          }

                          // Update shared preferences
                          SharedPreferences.getInstance().then(
                              (pref) => pref.setBool(gDriveConnected, true));

                          remoteChanged = true;

                          setState(() {
                            gDriveStatusOn = true;
                          });
                        }
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
                        if (twitterStatusOn) {
                          widget.twitterApiHelper.purgeData();
                        } else {
                          if (await widget.twitterApiHelper.authTwitter()) {
                            setState(() => twitterStatusOn = true);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse(context.locale == const Locale("en")
                        ? "https://forms.zoho.com/tagref/form/BugTracker"
                        : "https://forms.zoho.com/tagref/form/BugReportJP"));
                  },
                  child: const Text("Bug Report"),
                ))

            // Padding(
            //     padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            //     child: Row(
            //       children: [
            //         Expanded(
            //           child: SizedBox(
            //             width: (1.sw / 1.3).w,
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(tr("auto-tag"),
            //                     style: Theme.of(context).textTheme.titleMedium),
            //                 Padding(
            //                   padding: const EdgeInsets.symmetric(vertical: 10),
            //                   child: Text(tr("auto-tag-desc"),
            //                       style: Theme.of(context).textTheme.bodySmall),
            //                 )
            //               ],
            //             ),
            //           ),
            //         ),
            //         Padding(
            //           padding: EdgeInsets.fromLTRB(40.w, 0, 0, 0),
            //           child: const ToggleSwitch(),
            //         )
            //       ],
            //     ))
          ],
        ),
      ),
    );
  }

  /// Closes the current database connection, update the source db file to match
  /// remote version, and re-open the database connection
  Future<void> _compareRemoteDB() async {
    int version = await widget.gApiHelper.compareDB();

    if (version != 404) {
      // Ask for which version to keep
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                backgroundColor: desktopColorDark,
                title: Text(
                  tr("is-remote-replace-local"),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        widget.gApiHelper.pullAndReplaceLocalDB();
                        Navigator.pop(context);
                      },
                      child: Text(tr("yes"))),
                  TextButton(
                      onPressed: () {
                        widget.gApiHelper.pushDB();
                        Navigator.pop(context);
                      },
                      child: Text(tr("no"))),
                ],
              ),
          barrierDismissible: false);
    }
  }

  /// Removes all local configurations about google drive
  void disconnectGDrive() {
    SharedPreferences.getInstance().then((pref) => setState(() {
          pref.remove(gDriveConnected);
        }));
    widget.gApiHelper.isInitialized = false;
    widget.gApiHelper.purgeAccessCredentials(secureStorage);
    Navigator.pop(context);
    setState(() {
      gDriveStatusOn = true;
    });
  }
}
