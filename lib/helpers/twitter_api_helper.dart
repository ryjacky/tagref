import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tagref/main.dart';
import 'package:tagref/screen/twitter_oauth_exchange.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class TwitterApiHelper {
  late final TwitterApi twitterClient;
  bool authorized = false;

  late final String userId;
  final FlutterSecureStorage secureStorage;

  final tTokenSSKey = "com.tagref.twitterUserToken";
  final uidSSKey = "com.tagref.twitterUserId";
  final refreshTokenSSKey = "com.tagref.twitterRefreshToken";

  final BuildContext context;

  TwitterApiHelper({required this.context, required this.secureStorage});

  Future<bool> authTwitter() async {
    if (authorized) {
      log("Twitter client is already authorized, skipping...");
      return true;
    }

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
      } catch (e) {
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
      Navigator.push(
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
              pageBuilder: (context, a1, a2) =>
                  const TwitterOAuthExchange())).then((token) {
        // Save and apply userId and access token
        twitterClient = TwitterApi(bearerToken: token["access_token"]);
        twitterClient.usersService.lookupMe().then((value) {
          log("Twitter oauth consent has returned, continuing with the result");

          userId = value.data.id;
          secureStorage.write(key: tTokenSSKey, value: token["access_token"]);
          secureStorage.write(key: refreshTokenSSKey, value: token["refresh_token"]);
          secureStorage.write(key: uidSSKey, value: userId);
          authorized = true;
        });
      });
    }

    return true;
  }

  /// Look up the reverse chronological home timeline for the user and
  /// retrieve all images in its url form, includes retweets, excludes replies
  ///
  /// Returns a list of string containing image urls
  Future<List<String>> lookupHomeTimelineImages() async {
    List<String> imageUrls = [];

    // Query for home timeline
    log("Fetching home timeline images for the users, extracting from tweets");
    TwitterResponse<List<TweetData>, TweetMeta> response = await twitterClient
        .tweetsService
        .lookupHomeTimeline(userId: userId, maxResults: 50, excludes: [
      ExcludeTweetType.replies
    ], expansions: [
      TweetExpansion.attachmentsMediaKeys,
      TweetExpansion.referencedTweetsId
    ], mediaFields: [
      MediaField.url
    ]);

    imageUrls.addAll(_extractImageUrlFromResponse(response));

    // Search for all retweets in home timeline, add image urls from the
    // original tweets to imageUrls when available
    log("Fetching home timeline images for the users, extracting from retweets");
    List<String> retweetIds = [];
    for (TweetData tweetData in response.data) {
      // Gather retweets
      if (tweetData.referencedTweets != null &&
          tweetData.referencedTweets!.isNotEmpty) {
        retweetIds.add(tweetData.referencedTweets!.first.id);
      }
    }

    // Query for retweets
    TwitterResponse<List<TweetData>, void> retweetResponse = await twitterClient
        .tweetsService
        .lookupByIds(tweetIds: retweetIds, expansions: [
      TweetExpansion.attachmentsMediaKeys,
      TweetExpansion.referencedTweetsId
    ], mediaFields: [
      MediaField.url
    ]);

    imageUrls.addAll(_extractImageUrlFromResponse(retweetResponse));

    return imageUrls;
  }

  /// Takes in a TwitterResponse, extract the image url when an image is included
  /// in the tweet.
  ///
  /// Returns a list of string containing the image urls extracted.
  List<String> _extractImageUrlFromResponse(TwitterResponse response) {
    List<String> imageUrls = [];
    if (response.hasIncludes && response.includes?.media != null) {
      // Add all image urls for response tweets to imageUrls when available
      // excludes retweets
      for (MediaData mediaData in response.includes!.media!) {
        if (mediaData.type == MediaType.photo && mediaData.url != null) {
          imageUrls.add(mediaData.url!);
        }
      }
    }

    return imageUrls;
  }
}
