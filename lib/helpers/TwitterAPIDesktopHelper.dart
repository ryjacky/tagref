import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/helpers/TwitterAPIHelper.dart';
import 'package:tagref/oauth/oauth_credentials.dart';
import 'package:tagref/oauth/oauth_server.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class TwitterAPIDesktopHelper extends TwitterAPIHelper {
  TwitterAPIDesktopHelper(
      TwitterApi api, String uid)
      : super(api) {
    currTwitterUID = uid;
    api.tweetsService
        .lookupHomeTimeline(userId: currTwitterUID, maxResults: 5)
        .then((value) => untilTweetId = int.parse(value.data.last.id));
  }

  @override
  Future<Map<String, String>> lookupHomeTimelineImages() async {
    // Query for home timeline tweets
    log("Fetching home timeline images for the users, extracting from tweets");
    TwitterResponse<List<TweetData>, TweetMeta> response;

    log("Until tweet id: $untilTweetId");

    response = await api.tweetsService.lookupHomeTimeline(
        untilTweetId: untilTweetId.toString(),
        userId: currTwitterUID,
        maxResults: 100,
        excludes: [
          ExcludeTweetType.replies
        ],
        tweetFields: [
          TweetField.referencedTweets
        ],
        expansions: [
          TweetExpansion.attachmentsMediaKeys,
        ],
        mediaFields: [
          MediaField.url
        ]);

    untilTweetId = int.parse(response.data.last.id);
    Map<String, String> tweetIdToImgURL = {};

    // Separate original tweets (with attachment) and retweets (with/without attachment)
    List<TweetData> originalTweetData = [];
    List<String> retweetIds = [];

    for (int i = 0; i < response.data.length; i++) {
      if (response.data[i].referencedTweets != null) {
        retweetIds.addAll(response.data[i].referencedTweets!
            .map((retweet) => retweet.id)
            .toList());
      } else {
        originalTweetData.add(response.data[i]);
      }
    }

    tweetIdToImgURL.addAll(
        extractImageUrlFromResponse(originalTweetData, response.includes!));

    // Retrieve retweets with attachment
    List<TweetData> retweetData = [];

    TwitterResponse<List<TweetData>, void> retweetResponse =
        await api.tweetsService.lookupByIds(tweetIds: retweetIds, expansions: [
      TweetExpansion.attachmentsMediaKeys,
    ], mediaFields: [
      MediaField.url
    ]);

    retweetData.addAll(retweetResponse.data);

    tweetIdToImgURL.addAll(
        extractImageUrlFromResponse(retweetData, retweetResponse.includes!));

    return tweetIdToImgURL;
  }

  @override
  Map<String, String> extractImageUrlFromResponse(
      List<TweetData> tweetData, Includes includes) {
    Map<String, String> mediaKeyToTweetId = {};
    for (int i = 0; i < tweetData.length; i++) {
      if (tweetData[i].attachments != null &&
          tweetData[i].attachments!.mediaKeys != null) {
        for (int j = 0; j < tweetData[i].attachments!.mediaKeys!.length; j++) {
          mediaKeyToTweetId.putIfAbsent(
              tweetData[i].attachments!.mediaKeys![j], () => tweetData[i].id);
        }
      }
    }

    Map<String, String> tweetIdToImgURL = {};
    for (int i = 0; i < includes.media!.length; i++) {
      if (mediaKeyToTweetId.containsKey(includes.media![i].key) &&
          includes.media![i].url != null) {
        tweetIdToImgURL.putIfAbsent(mediaKeyToTweetId[includes.media![i].key]!,
            () => includes.media![i].url!);
      }
    }

    return tweetIdToImgURL;
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

    String? uid = await secureStorage.read(key: TwitterAPIHelper.twitterUID);
    String? accessToken =
        await secureStorage.read(key: TwitterAPIHelper.twitterToken);
    String? refreshToken =
        await secureStorage.read(key: TwitterAPIHelper.twitterRefreshToken);

    OAuthCredentials? cred;

    if (uid != null && accessToken != null && refreshToken != null) {
      // Refresh accessToken

      log("Refreshing access token");
      cred = await OAuthServer.twitterRefreshAccessToken(refreshToken);
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

    // Save user credentials to local secure storage
    log("Saving user credentials");
    secureStorage.write(
        key: TwitterAPIHelper.twitterToken, value: cred.accessToken);
    secureStorage.write(
        key: TwitterAPIHelper.twitterRefreshToken, value: cred.refreshToken);

    TwitterApi api = TwitterApi(bearerToken: cred.accessToken);
    secureStorage.write(
        key: TwitterAPIHelper.twitterUID,
        value: (await api.usersService.lookupMe()).data.id);

    return api;
  }
}
