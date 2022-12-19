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
  Future<Map<String, String>> lookupHomeTimelineImages();

  /// Takes in a TwitterResponse, extract the image url when an image is included
  /// in the tweet.
  ///
  /// Returns a list of string containing the image urls extracted.
  Map<String, String> extractImageUrlFromResponse(List<TweetData> tweetData,
      Includes includes);

  /// Permanently remove user credentials from the local secure storage
  static void purgeUserCredentials(FlutterSecureStorage secureStorage){
    // Permanently delete user credentials from pc
    secureStorage.delete(key: TwitterAPIHelper.twitterToken);
    secureStorage.delete(key: TwitterAPIHelper.twitterUID);
    secureStorage.delete(key: TwitterAPIHelper.twitterRefreshToken);
  }
}
