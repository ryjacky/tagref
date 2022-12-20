import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tagref/assets/constant.dart';
import 'package:tagref/oauth/oauth_credentials.dart';
import 'package:tagref/oauth/oauth_server.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

abstract class TwitterAPIHelper {
  /// Secure storage key for twitter access token
  static const twitterToken = "com.tagref.twitterUserToken";

  /// Secure storage key for twitter user id
  static const twitterUID = "com.tagref.twitterUserId";

  /// Secure storage key for twitter refresh token
  static const twitterRefreshToken = "com.tagref.twitterRefreshToken";

  /// Secure storage key for twitter refresh token
  static const twitterTokenExpire = "com.tagref.tokenExpire";

  @protected final TwitterApi api;
  @protected final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  /// Current twitter user id
  @protected late final String currTwitterUID;

  /// Twitter api retrieve post until id
  @protected String? untilTweetId;

  TwitterAPIHelper(this.api);

  /// Look up the reverse chronological home timeline for the user and
  /// retrieve all images in its url form, includes retweets, excludes replies
  ///
  /// Returns a list of string containing image urls
  Future<Map<String, String>> lookupHomeTimelineImages() async {
    // Query for home timeline tweets
    log("Fetching home timeline images for the users, extracting from tweets");
    TwitterResponse<List<TweetData>, TweetMeta> response;

    untilTweetId ??= (await api.tweetsService
        .lookupHomeTimeline(userId: currTwitterUID, maxResults: 100)).data.last.id;

    log("Until tweet id: $untilTweetId");

    response = await api.tweetsService.lookupHomeTimeline(
        untilTweetId: untilTweetId,
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

    untilTweetId = response.data.last.id;
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

  /// Takes in a TwitterResponse, extract the image url when an image is included
  /// in the tweet.
  ///
  /// Returns a list of string containing the image urls extracted.
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

  /// Permanently remove user credentials from the local secure storage
  static void purgeUserCredentials(FlutterSecureStorage secureStorage){
    // Permanently delete user credentials from pc
    secureStorage.delete(key: TwitterAPIHelper.twitterToken);
    secureStorage.delete(key: TwitterAPIHelper.twitterUID);
    secureStorage.delete(key: TwitterAPIHelper.twitterRefreshToken);
  }
}
