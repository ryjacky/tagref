import 'dart:convert';
import 'dart:developer';
import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/datastream/v1.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/youtube/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/assets/db_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleApiHelper {
  drive.DriveApi? driveApi;

  /// Base client used by the Google Drive API
  final http.Client _baseClient = http.Client();

  /// Client ID and secret obtained from Google Cloud Console
  final ClientId _clientId = ClientId(
      '252111377436-r8hlo5t1l81rjv0ov4nhfojrktrjnih2.apps.googleusercontent.com',
      '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');

  final FlutterSecureStorage secureStorage;
  late AuthClient _authClient;

  final String localDBPath;
  final String dbFileName;

  bool isInitialized = false;

  GoogleApiHelper(
      {required this.localDBPath,
      required this.dbFileName,
      required this.secureStorage});

  Future<bool> updateLocalDB(bool pullOnly) async {
    if (!isInitialized) {
      log("Drive API has not yet been initialized");
      return false;
    }

    int versionDifference = await compareDB();
    if (versionDifference > 0) {
      log("Remote version of the database is newer, downloading...");
      return await pullAndReplaceLocalDB();

    } else {
      log("Local file is up to date");

      return true;
    }
  }

  Future<void> initializeAuthClient() async {
    // check if accessCredential is already available
    String? accessCredentialsJString =
    await secureStorage.read(key: gAccessCredential);

    if (accessCredentialsJString != null) {
      // Build the auth client from secure secureStorage
      _authClient = autoRefreshingClient(
          _clientId,
          AccessCredentials.fromJson(jsonDecode(accessCredentialsJString)),
          _baseClient);

    } else {
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
        // // Login for desktop
        // // GoogleSignIn library is not available for desktop
        // // Using googleapis_auth library
        _authClient = await obtainCredentials();

        // Write to the secure secureStorage
        secureStorage.write(
            key: gAccessCredential,
            value: jsonEncode(_authClient.credentials.toJson()));
      }
    }

  }

  /// Initializes google api when user has logged in before (desktop/mobile flow)
  Future<void> initializeGoogleApi() async {
    if (driveApi != null) {
      log("Google API have already been initialized!");
    }

    driveApi = drive.DriveApi(_authClient);

    // Check for validity of locally stored access credentials
    try {
      await driveApi!.files.list(spaces: "appDataFolder");
      isInitialized = true;
    } catch (e) {
      // Erase locally stored access credentials when it is invalid and
      // try to obtain new credentials
      driveApi = null;
      await secureStorage.delete(key: gAccessCredential);
      throw Exception(
          "Google API initialization failed, cannot obtain access credentials.");
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

  Future<int> compareDB() async {
    if (!isInitialized) {
      log("Drive API has not yet been initialized");
      return 404;
    }

    // Check and compare the database version of remote and local
    drive.FileList appDataFileList = await driveApi!.files.list(
        spaces: "appDataFolder",
        q: "name='$dbFileName'",
        $fields: "files/modifiedTime");

    var localDBFile = File(join(localDBPath, dbFileName));

    // Upload or update the local db file based on the search result
    if (appDataFileList.files!.isNotEmpty) {
      Duration versionDifference = appDataFileList.files!.first.modifiedTime!
          .difference(await localDBFile.lastModified());

      if ((versionDifference.inSeconds).abs() <= 5){
        return 0;
      } else if (versionDifference.isNegative) {
        return -1;
      } else {
        return 1;
      }
    } else {
      log("Remote database does not exist.");
      return 404;
    }
  }

  /// Downloads the remote version of the database that is named [dbFileName]
  /// and updates the local copy located at [dbParent].
  /// Returns null if there is no remote copy of the file and returns the file
  /// itself if the remote copy is available.
  ///
  /// You SHOULD close all database connection before calling this method
  Future<bool> pullAndReplaceLocalDB() async {
    if (driveApi == null) {
      log("Google API has not been initialized!");
      return false;
    }

    // Search for tagref_db.db
    drive.FileList appDataFileList = await driveApi!.files
        .list(spaces: "appDataFolder", q: "name='$dbFileName'");

    // Upload or update the local db file based on the search result
    if (appDataFileList.files!.isNotEmpty) {
      var localDBFile = File(join(localDBPath, dbFileName)).openWrite();

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

  Future<bool> pushDB() async {
    if (!isInitialized) {
      log("Google API has not been initialized!");
      return false;
    }

    log("Start pushing database to remote");
    String url = join(localDBPath, dbFileName);

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
  void purgeAccessCredentials(FlutterSecureStorage secureStorage) {
    secureStorage.delete(key: gAccessCredential);
    driveApi = null;
  }
}
