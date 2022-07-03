import 'dart:convert';
import 'dart:typed_data';

import 'package:googleapis/youtube/v3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tagref/assets/DBHelper.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/datastream/v1.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:tagref/assets/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File, Platform;

late drive.DriveApi driveApi;

/// Base client used by the Google Drive API
final http.Client _baseClient = http.Client();

ClientId _clientId = ClientId(
    '252111377436-r8hlo5t1l81rjv0ov4nhfojrktrjnih2.apps.googleusercontent.com',
    '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');

// Controls Google Sign In flow (desktop/mobile flow)
Future<void> initializeGoogleApi() async {
  // check if accessCredential is already available
  const storage = FlutterSecureStorage();

  String? accessCredentialsJString = await storage.read(key: gAccessCredential);

  late AuthClient client;

  // Build the auth client
  if (accessCredentialsJString == null) {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        // Using GoogleSignIn library
        final GoogleSignIn _googleSignIn =
            GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]);

        await _googleSignIn.signIn();
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } else {
      // Login for desktop
      // GoogleSignIn library is not available for desktop
      // Using googleapis_auth library
      client = await obtainCredentials();

      // Write to the secure storage
      storage.write(
          key: gAccessCredential,
          value: jsonEncode(client.credentials.toJson()));
    }
  } else {
    client = autoRefreshingClient(
        _clientId,
        AccessCredentials.fromJson(jsonDecode(accessCredentialsJString)),
        _baseClient);
  }

  driveApi = drive.DriveApi(client);
}

// Google Sign in function for desktop (mac, windows, linux?)
Future<AuthClient> obtainCredentials() async => await clientViaUserConsent(
    _clientId, [drive.DriveApi.driveAppdataScope], _prompt,
    baseClient: _baseClient);

// prompt for user to log in (Opens authentication link with browser)
void _prompt(String url) {
  launchUrl(Uri.parse(url));
}

/// Downloads the remote version of the database that is named [dbFileName]
/// and updates the local copy located at [dbParent].
/// Returns null if there is no remote copy of the file and returns the file
/// itself if the remote copy is available.
Future<bool> pullDB(String dbParent, String dbFileName) async {
  // Search for tagref_db.db
  drive.FileList appDataFileList = await driveApi.files
      .list(spaces: "appDataFolder", q: "name='$dbFileName'");

  // Upload or update the local db file based on the search result
  if (appDataFileList.files!.isNotEmpty) {
    var localDBFile = File(await DBHelper.getDBUrl()).openWrite();

    Media remoteDBMedia = await driveApi.files.get(
        appDataFileList.files!.first.id!,
        downloadOptions: DownloadOptions.fullMedia) as Media;

    localDBFile.addStream(remoteDBMedia.stream).whenComplete(() {
      localDBFile.flush();
      localDBFile.close();
    });

    return true;
  } else {
    return false;
  }
}

void pushDB(String dbParent, String dbFileName) async {
  String url = join(dbParent, dbFileName);

  if (url.contains(".db") ||
      url.contains(".sqlite") ||
      url.contains(".sqlite3")) {
    // Prepare the file for drive upload
    // Create "Google Drive File" (meta data)
    drive.File dbFileUpload = drive.File();
    dbFileUpload.name = "tagref_db.db";

    // Read db file and create Media for drive api to upload
    File dbFile = File(url);
    var dbFileStream = dbFile.openRead().asBroadcastStream();
    var dbFileStreamLength = dbFile.lengthSync();
    drive.Media uploadMedia = drive.Media(dbFileStream, dbFileStreamLength);

    // Search for tagref_db.db
    drive.FileList appDataFileList = await driveApi.files
        .list(spaces: "appDataFolder", q: "name='$dbFileName'");

    // Upload or update db file based on the search result
    if (appDataFileList.files!.isNotEmpty) {
      driveApi.files.update(dbFileUpload, appDataFileList.files!.first.id!,
          uploadMedia: uploadMedia);
    } else {
      dbFileUpload.parents = ["appDataFolder"];
      driveApi.files.create(dbFileUpload, uploadMedia: uploadMedia);
    }
  } else {
    throw Error(
        message: "Unknown file type!",
        reason:
            "Either the url is wrong or the database file type is not supported.");
  }
}
