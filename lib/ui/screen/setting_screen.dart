import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/helpers/TwitterAPIDesktopHelper.dart';
import 'package:tagref/helpers/TwitterAPIHelper.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/oauth/oauth_server.dart';
import 'package:tagref/ui/components/buttons.dart';
import 'package:tagref/ui/components/floaty_loader.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingFragment extends StatefulWidget {

  const SettingFragment({Key? key}) : super(key: key);

  @override
  State<SettingFragment> createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  late final GoogleApiHelper gApiHelper;

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
    log("Setting fragment initState()");

    Future.wait([
      secureStorage.read(key: TwitterAPIHelper.twitterUID),
      secureStorage.read(key: TwitterAPIHelper.twitterRefreshToken),
      secureStorage.read(key: TwitterAPIHelper.twitterToken),
    ]).then((value) {
      log(value.toString());

      if (value[0] != null && value[1] != null && value[2] != null) {
        setState(() {
          twitterStatusOn = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((pref) => setState(() {
          gDriveStatusOn = pref.getBool(gDriveConnected) != null ? true : false;
        }));

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
                          if (!gApiHelper.isInitialized) {
                            await gApiHelper.initializeAuthClient();
                            await gApiHelper.initializeGoogleApi();
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
                          // Disconnect twitter
                          TwitterAPIHelper.purgeUserCredentials(secureStorage);
                          setState(() => twitterStatusOn = false);
                        } else {
                          // Authorize twitter
                          if (Platform.isMacOS ||
                              Platform.isWindows ||
                              Platform.isLinux) {
                            FloatyLoader fl = FloatyLoader(
                              context: context,
                              onCancel: () {
                                OAuthServer.forceClose();
                                log("OAuth is canceled by the user.");
                              },
                            );
                            fl.startsLoadingForResult();

                            if ((await TwitterAPIDesktopHelper
                                    .getAuthClient()) !=
                                null) {
                              setState(() {
                                twitterStatusOn = true;
                              });
                              fl.closeLoader();
                            }
                          } else if (Platform.isIOS || Platform.isAndroid) {
                          } else {}
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
    int version = await gApiHelper.compareDB();

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
                        gApiHelper.pullAndReplaceLocalDB();
                        Navigator.pop(context);
                      },
                      child: Text(tr("yes"))),
                  TextButton(
                      onPressed: () {
                        gApiHelper.pushDB();
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
    gApiHelper.isInitialized = false;
    gApiHelper.purgeAccessCredentials(secureStorage);
    Navigator.pop(context);
    setState(() {
      gDriveStatusOn = true;
    });
  }
}
