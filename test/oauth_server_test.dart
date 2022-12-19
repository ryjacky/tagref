import 'package:flutter/foundation.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/oauth/oauth_credentials.dart';
import 'package:tagref/oauth/oauth_server.dart';
import 'package:test/test.dart';
void main() async {
  test("Test oauth server connection", () async {
    const String authUrl =
        "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=$twitterClientId&redirect_uri=$twitterCallback&scope=offline.access%20tweet.read%20users.read%20follows.read&state=state&code_challenge=challenge&code_challenge_method=plain";

    // Start OAuth server and launch user consent
    OAuthCredentials? cred = await OAuthServer().listen(Uri.parse(authUrl));

    print("The access token is ${cred!.accessToken.substring(0, 5)}\n");
    print("The refresh token is ${cred.refreshToken.substring(0, 5)}");

    expect(cred.accessToken != "null" && cred.refreshToken != "null", equals(true));

  });
}