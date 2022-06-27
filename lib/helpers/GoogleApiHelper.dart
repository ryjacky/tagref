import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:tagref/assets/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

late DriveApi driveApi;

// Controls Google Sign In flow (desktop/mobile flow)
Future<void> googleApiSignIn() async {
  // check if accessCredential is already available
  const storage = FlutterSecureStorage();

  String? accessCredentialsJString = await storage.read(key: gAccessCredential);

  if (accessCredentialsJString == null) {
    // TODO: ADD LOGIN HERE
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final GoogleSignIn _googleSignIn =
            GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive']);

        await _googleSignIn.signIn();
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } else {
      // Login for desktop
      AuthClient client = await obtainCredentials();
      print(client.credentials.toJson().toString());
      storage.write(
          key: gAccessCredential,
          value: client.credentials.toJson().toString());
    }
  } else {
    // TODO: Take LOGIN here
    print(accessCredentialsJString);
  }
}

// Google Sign in function for desktop (mac, windows, linux?)
Future<AuthClient> obtainCredentials() async => await clientViaUserConsent(
      ClientId(
          '252111377436-r8hlo5t1l81rjv0ov4nhfojrktrjnih2.apps.googleusercontent.com',
          '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'),
      ['https://www.googleapis.com/auth/drive'],
      _prompt,
    );

// prompt for user to log in (Opens authentication link with browser)
void _prompt(String url) {
  launchUrl(Uri.parse(url));
}

// Initializes variable driveApi, need to be invoked every time
// tagref starts
void initializeDriveApi(AuthClient client) async {
  driveApi = DriveApi(client);
}
