import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagref/assets/db_helper.dart';
import 'package:tagref/assets/font_size.dart';
import 'package:tagref/ui/toggle_switch.dart';

import '../assets/constant.dart';
import '../helpers/google_api_helper.dart';
import '../helpers/icloud_api_helper.dart';
import '../ui/drive_status_display.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final secureStorage = FlutterSecureStorage();

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
                      child: DriveStatusDisplay(
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
                            if (driveApi == null) {
                              await initializeGoogleApi(secureStorage);
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
                      padding: const EdgeInsets.all(8),
                      child: DriveStatusDisplay(
                        driveLogoSrc: "assets/images/gdrive_logo.svg",
                        driveName: tr("icloud"),
                        onTap: () => iCloudSignIn(),
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
    await DBHelper.db.close();
    await pullAndReplaceLocalDB(
        (await getApplicationSupportDirectory()).path, DBHelper.dbFileName);
    await DBHelper.initializeDatabase();
  }

  /// Removes all local configurations about google drive
  void disconnectGDrive() {
    SharedPreferences.getInstance().then((pref) => setState(() {
          pref.remove(gDriveConnected);
        }));
    purgeAccessCredentials(secureStorage);
    Navigator.pop(context);
    setState(() {
      gDriveStatusOn = true;
    });
  }
}

class SettingFragment extends StatefulWidget {
  const SettingFragment({Key? key}) : super(key: key);

  @override
  State<SettingFragment> createState() => _SettingScreenFragmentState();
}

class _SettingScreenFragmentState extends State<SettingFragment> {
  final secureStorage = FlutterSecureStorage();

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

    return Padding(
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
            child: Text(tr("linked-drives"),
                style: Theme.of(context).textTheme.headlineLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: DriveStatusDisplay(
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
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(tr("no"))),
                                  ],
                                ),
                            barrierDismissible: false);
                      } else {
                        // The only case when driveApi will be null should be
                        // when GDrive has never been set up before
                        if (driveApi == null) {
                          await initializeGoogleApi(secureStorage);
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
                  padding: const EdgeInsets.all(8),
                  child: DriveStatusDisplay(
                    driveLogoSrc: "assets/images/gdrive_logo.svg",
                    driveName: tr("icloud"),
                    onTap: () => iCloudSignIn(),
                  ),
                ),
              ],
            ),
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
                              style: Theme.of(context).textTheme.headlineLarge),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(tr("auto-tag-desc"),
                                style: Theme.of(context).textTheme.bodySmall),
                          )
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
    );
  }

  /// Closes the current database connection, update the source db file to match
  /// remote version, and re-open the database connection
  Future<void> _applyRemoteDBChanges() async {
    await DBHelper.db.close();
    await pullAndReplaceLocalDB(
        (await getApplicationSupportDirectory()).path, DBHelper.dbFileName);
    await DBHelper.initializeDatabase();
  }

  /// Removes all local configurations about google drive
  void disconnectGDrive() {
    SharedPreferences.getInstance().then((pref) => setState(() {
          pref.remove(gDriveConnected);
        }));
    purgeAccessCredentials(secureStorage);
    Navigator.pop(context);
    setState(() {
      gDriveStatusOn = true;
    });
  }
}
