import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/helpers/TwitterAPIDesktopHelper.dart';
import 'package:tagref/helpers/TwitterAPIHelper.dart';
import 'package:tagref/oauth/oauth_credentials.dart';
import 'package:tagref/oauth/oauth_server.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class TwitterAPIMobileHelper extends TwitterAPIHelper {
  TwitterAPIMobileHelper(TwitterApi api, String uid) : super(api) {
    currTwitterUID = uid;
  }

  /// Retrieve access token through user consent if login credentials not
  /// locally available, retrieve from secure storage otherwise.
  ///
  /// If authorization is success, save access token and refresh token to
  /// secure storage.
  ///
  /// Returns a auth client (TwitterApi object) when success, null otherwise.
  static Future<TwitterApi?> getAuthClient() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();

    List<String?> localCred = await Future.wait([
      secureStorage.read(key: TwitterAPIHelper.twitterUID),
      secureStorage.read(key: TwitterAPIHelper.twitterToken),
      secureStorage.read(key: TwitterAPIHelper.twitterRefreshToken),
      secureStorage.read(key: TwitterAPIHelper.twitterTokenExpire),
    ]);

    String? uid = localCred[0];
    String? accessToken = localCred[1];
    String? refreshToken = localCred[2];
    String? expireTime = localCred[3] ??
        DateTime.now().subtract(const Duration(days: 1)).toString();

    OAuthCredentials? cred;

    if (uid != null && accessToken != null && refreshToken != null) {
      // All credentials are locally available
      // Refresh accessToken if expired
      if (DateTime.now().isAfter(DateTime.parse(expireTime))) {
        log("Refreshing access token");
        cred = await OAuthServer.twitterRefreshAccessToken(refreshToken);
      } else {
        log("Access token not expired");
        cred = OAuthCredentials(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expires: DateTime.parse(expireTime));
      }
    } else {
      // Get access token through user consent
      log("Generating access token");

      const String authUrl =
          "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=$twitterClientId&redirect_uri=$twitterCallback&scope=offline.access%20tweet.read%20users.read%20follows.read&state=state&code_challenge=challenge&code_challenge_method=plain";

      // Start OAuth server and launch user consent
      cred = await OAuthServer.listen(Uri.parse(authUrl), OAuthType.twitter);

      // Create auth client
      if (cred == null) return null;
    }
    log("Access expire time: ${cred.expires.toString()}");

    // Save user credentials to local secure storage
    log("Saving user credentials");
    secureStorage.write(
        key: TwitterAPIHelper.twitterToken, value: cred.accessToken);
    secureStorage.write(
        key: TwitterAPIHelper.twitterRefreshToken, value: cred.refreshToken);
    secureStorage.write(
        key: TwitterAPIHelper.twitterTokenExpire, value: cred.expires.toString());

    TwitterApi api = TwitterApi(bearerToken: cred.accessToken);
    secureStorage.write(
        key: TwitterAPIHelper.twitterUID,
        value: (await api.usersService.lookupMe()).data.id);

    return api;
  }
}
