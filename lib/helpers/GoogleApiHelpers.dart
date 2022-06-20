import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

late DriveApi driveApi;

// Used for _handleSignIn()
final GoogleSignIn _googleSignIn =
    GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive']);

// Google Sign in function for iOS and android
Future<void> _handleSignIn() async {
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

// Grant google api access
void _prompt(String url) {
  launchUrl(Uri.parse(url));
}

void initializeDriveApi(AuthClient client) async {
  driveApi = DriveApi(client);
}
