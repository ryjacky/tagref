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

drive.DriveApi? driveApi;

const secureStorage = FlutterSecureStorage();

/// Base client used by the Google Drive API
final http.Client _baseClient = http.Client();

/// Client ID and secret obtained from Google Cloud Console
ClientId _clientId = ClientId(
    '252111377436-r8hlo5t1l81rjv0ov4nhfojrktrjnih2.apps.googleusercontent.com',
    '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');

/// Initialize Google API, connect to GDrive, download remote db file
/// All database connections should be closed before calling this function
Future<void> initializeDriveApiAndPullDB(
    String localDBPath, String dbFileName) async {
  await initializeGoogleApi();
  pullAndReplaceLocalDB(localDBPath, dbFileName);
}

/// Controls Google Sign In flow (desktop/mobile flow)
Future<void> initializeGoogleApi() async {
  if (driveApi != null) {
    throw Exception(
        "Google API have already been initialized, you should not initialize it twice!");
  }

  // check if accessCredential is already available
  String? accessCredentialsJString =
      await secureStorage.read(key: gAccessCredential);

  late AuthClient client;

  if (accessCredentialsJString == null) {
    // Build the auth client with user consent

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

      // Write to the secure secureStorage
      secureStorage.write(
          key: gAccessCredential,
          value: jsonEncode(client.credentials.toJson()));
    }
  } else {
    // Build the auth client from secure secureStorage
    client = autoRefreshingClient(
        _clientId,
        AccessCredentials.fromJson(jsonDecode(accessCredentialsJString)),
        _baseClient);
  }

  driveApi = drive.DriveApi(client);

  // Check for validity of locally stored access credentials
  try {
    drive.FileList appDataFileList =
        await driveApi!.files.list(spaces: "appDataFolder");
  } catch (e) {
    // Erase locally stored access credentials when it is invalid and
    // try to obtain new credentials
    driveApi = null;
    await secureStorage.delete(key: gAccessCredential);
    await initializeGoogleApi();
  }
}

/// Google Sign in function for desktop (mac, windows, linux?)
Future<AuthClient> obtainCredentials() async => await clientViaUserConsent(
    _clientId, [drive.DriveApi.driveAppdataScope], _prompt,
    baseClient: _baseClient);

/// prompt for user consent (Opens authentication link with browser)
void _prompt(String url) {
  launchUrl(Uri.parse(url));
}

/// Downloads the remote version of the database that is named [dbFileName]
/// and updates the local copy located at [dbParent].
/// Returns null if there is no remote copy of the file and returns the file
/// itself if the remote copy is available.
///
/// You SHOULD close all database connection before calling this method
Future<bool> pullAndReplaceLocalDB(String dbParent, String dbFileName) async {
  if (driveApi == null) {
    throw GoogleAPINotInitializedException(
        "Google API has not been initialized!");
  }

  // Search for tagref_db.db
  drive.FileList appDataFileList = await driveApi!.files
      .list(spaces: "appDataFolder", q: "name='$dbFileName'");

  // Upload or update the local db file based on the search result
  if (appDataFileList.files!.isNotEmpty) {
    var localDBFile = File(await DBHelper.getDBUrl()).openWrite();

    Media remoteDBMedia = await driveApi!.files.get(
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

Future<bool> pushDB(String dbParent, String dbFileName) async {
  if (driveApi == null) {
    throw GoogleAPINotInitializedException(
        "Google API has not been initialized!");
  }

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
    drive.FileList appDataFileList = await driveApi!.files
        .list(spaces: "appDataFolder", q: "name='$dbFileName'");

    // Upload or update db file based on the search result
    if (appDataFileList.files!.isNotEmpty) {
      driveApi!.files.update(dbFileUpload, appDataFileList.files!.first.id!,
          uploadMedia: uploadMedia);
    } else {
      dbFileUpload.parents = ["appDataFolder"];
      driveApi!.files.create(dbFileUpload, uploadMedia: uploadMedia);
    }
  } else {
    throw Error(
        message: "Unknown file type!",
        reason:
            "Either the url is wrong or the database file type is not supported.");
  }

  return true;
}

/// Remove all locally stored credentials, clear active driveApi instances
void purgeAccessCredentials() {
  secureStorage.delete(key: gAccessCredential);
  driveApi = null;
}

class GoogleAPINotInitializedException implements Exception {
  String cause;

  GoogleAPINotInitializedException(this.cause);
}
