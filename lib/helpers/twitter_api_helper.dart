import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tagref/helpers/twitter_oauth_exchange.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class TwitterApiHelper {
  late TwitterApi twitterClient;
  bool authorized = false;

  late String userId;
  final FlutterSecureStorage secureStorage;

  final tTokenSSKey = "com.tagref.twitterUserToken";
  final uidSSKey = "com.tagref.twitterUserId";
  final refreshTokenSSKey = "com.tagref.twitterRefreshToken";

  DateTime expires = DateTime.now();

  final BuildContext context;

  String untilId = "";

  TwitterApiHelper({required this.context, required this.secureStorage});

  Future<bool> purgeData() async {
    await secureStorage.delete(key: tTokenSSKey);
    await secureStorage.delete(key: uidSSKey);
    await secureStorage.delete(key: refreshTokenSSKey);

    authorized = false;

    return true;
  }

  Future<bool> authTwitter() async {
    expires = DateTime.now().add(const Duration(seconds: 7000));

    String? uid = await secureStorage.read(key: uidSSKey);
    String? accessToken = await secureStorage.read(key: tTokenSSKey);
    String? refreshToken = await secureStorage.read(key: refreshTokenSSKey);

    if (accessToken != null && uid != null && refreshToken != null) {
      log("Twitter OAUth credentials are found in system's secure storage");
      log("Creating twitter client with the stored credentials...");

      // Initializes twitterClient with the access token stored in
      // system's secure storage
      userId = uid;

      try {
        Map<String, String> token = await refreshAccessToken(refreshToken);
        secureStorage.write(key: tTokenSSKey, value: token["access_token"]);
        secureStorage.write(
            key: refreshTokenSSKey, value: token["refresh_token"]);

        twitterClient = TwitterApi(bearerToken: token["access_token"]!);
        authorized = true;

        return true;
      } catch (e) {
        // print(e);
        secureStorage.delete(key: uidSSKey);
        secureStorage.delete(key: tTokenSSKey);
        secureStorage.delete(key: refreshTokenSSKey);
        authorized = false;

        return false;
      }
    } else {
      log("Twitter client is not authorized");
      log("Twitter OAuth credentials not found locally");
      log("Sending user consent, please login with your browser");

      // Show twitter oauth 2.0 authorization page, save and apply userId and
      // access token when complete
      var token = await Navigator.push(
          context,
          PageRouteBuilder(
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0, -1.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                final tween = Tween(begin: begin, end: end);
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: curve,
                );

                return SlideTransition(
                  position: tween.animate(curvedAnimation),
                  child: child,
                );
              },
              pageBuilder: (context, a1, a2) => const TwitterOAuthExchange()));

      // Save and apply userId and access token
      twitterClient = TwitterApi(bearerToken: token["access_token"]);
      var value = await twitterClient.usersService.lookupMe();
      log("Twitter oauth consent has returned, continuing with the result");

      userId = value.data.id;
      await secureStorage.write(key: tTokenSSKey, value: token["access_token"]);
      await secureStorage.write(
          key: refreshTokenSSKey, value: token["refresh_token"]);
      await secureStorage.write(key: uidSSKey, value: userId);
      authorized = true;

      return true;
    }
  }

  /// Look up the reverse chronological home timeline for the user and
  /// retrieve all images in its url form, includes retweets, excludes replies
  ///
  /// Returns a list of string containing image urls
  Future<Map<String, String>> lookupHomeTimelineImages() async {
    // Query for home timeline tweets
    log("Fetching home timeline images for the users, extracting from tweets");
    TwitterResponse<List<TweetData>, TweetMeta> response;
    if (untilId == "") {
      response = await twitterClient.tweetsService
          .lookupHomeTimeline(userId: userId, maxResults: 100, excludes: [
        ExcludeTweetType.replies
      ], tweetFields: [
        TweetField.referencedTweets
      ], expansions: [
        TweetExpansion.attachmentsMediaKeys,
      ], mediaFields: [
        MediaField.url
      ]);
    } else {
      response = await twitterClient.tweetsService.lookupHomeTimeline(
          untilTweetId: untilId,
          userId: userId,
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
    }

    untilId = response.data.last.id;

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
        _extractImageUrlFromResponse(originalTweetData, response.includes!));

    // Retrieve retweets with attachment
    List<TweetData> retweetData = [];

    TwitterResponse<List<TweetData>, void> retweetResponse = await twitterClient
        .tweetsService
        .lookupByIds(tweetIds: retweetIds, expansions: [
      TweetExpansion.attachmentsMediaKeys,
    ], mediaFields: [
      MediaField.url
    ]);

    retweetData.addAll(retweetResponse.data);

    tweetIdToImgURL.addAll(
        _extractImageUrlFromResponse(retweetData, retweetResponse.includes!));

    return tweetIdToImgURL;
  }

  /// Takes in a TwitterResponse, extract the image url when an image is included
  /// in the tweet.
  ///
  /// Returns a list of string containing the image urls extracted.
  Map<String, String> _extractImageUrlFromResponse(
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

  void purgeLocalInfo() {
    secureStorage.delete(key: tTokenSSKey);
    secureStorage.delete(key: uidSSKey);
    secureStorage.delete(key: refreshTokenSSKey);
  }
}
