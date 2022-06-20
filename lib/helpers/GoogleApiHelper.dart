import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

late DriveApi driveApi;

// Used for _handleSignIn()
final GoogleSignIn _googleSignIn =
    GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive']);

// Controls Google Sign In flow (desktop/mobile flow)
Future<void> googleApiSignIn() async {
  // TODO: platform specific login function with condition
  try {
    await _googleSignIn.signIn();
  } catch (error) {
    print(error);
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
