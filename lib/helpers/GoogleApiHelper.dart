import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/datastream/v1.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:tagref/assets/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

late DriveApi driveApi;

final http.Client _baseClient = http.Client();

ClientId _clientId = ClientId(
    '252111377436-r8hlo5t1l81rjv0ov4nhfojrktrjnih2.apps.googleusercontent.com',
    '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');

// Controls Google Sign In flow (desktop/mobile flow)
Future<void> googleApiSignIn() async {
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
            GoogleSignIn(scopes: [DriveApi.driveAppdataScope]);

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

  initializeDriveApi(client);
}

// Google Sign in function for desktop (mac, windows, linux?)
Future<AuthClient> obtainCredentials() async =>
    await clientViaUserConsent(_clientId, [DriveApi.driveAppdataScope], _prompt,
        baseClient: _baseClient);

// prompt for user to log in (Opens authentication link with browser)
void _prompt(String url) {
  launchUrl(Uri.parse(url));
}

// Initializes variable driveApi, need to be invoked every time
// tagref starts
void initializeDriveApi(AuthClient client) async {
  driveApi = DriveApi(client);

  pushDB("lksjdf.db");
}

void pushDB(String url) {
  if (url.contains(".db") ||
      url.contains(".sqlite") ||
      url.contains(".sqlite3")) {
    File dbFile = File();
    dbFile.name = "tagref_db.db";
    dbFile.mimeType = "application/vnd.sqlite3";

    driveApi.files.create(dbFile);
  } else {
    throw Error(
        message: "Unknown file type!",
        reason:
            "Either the url is wrong or the database file type is not supported.");
  }
}
