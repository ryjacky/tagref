import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';

class TwitterApiHelper {
  late final TwitterApi twitterClient;

  late final String userId;
  final FlutterSecureStorage secureStorage;

  final tTokenSSKey = "com.tagref.twitterUserToken";
  final uidSSKey = "com.tagref.twitterUserId";

  TwitterApiHelper({required this.secureStorage}) {
    secureStorage.read(key: uidSSKey).then((uid) {
      secureStorage.read(key: tTokenSSKey).then((tToken) {
        if (tToken != null && uid != null) {
          userId = uid;
          twitterClient = TwitterApi(bearerToken: tToken);
        } else {
          authTwitterMobile().then((response) {
            twitterClient = TwitterApi(
              bearerToken: response.authToken!,

              //! The default timeout is 10 seconds.
              timeout: const Duration(seconds: 20),
            );

            twitterClient.usersService.lookupMe().then((myData) {
              userId = myData.data.id;

              secureStorage.write(
                  key: tTokenSSKey, value: response.authToken);
              secureStorage.write(key: uidSSKey, value: userId);
            });
          });
        }
      });
    });
  }

  Future<AuthResult> authTwitterMobile() async {
    final twitterLogin = TwitterLogin(
      apiKey: 'o02QkROyeZ34MMN7bnuNycUxe',
      apiSecretKey: 'IdETUEilwnLdMN0C04HNS0dSuYQ4XCl3WJR675sPtG0Jf3GTnD',
      redirectURI: 'com.tagref.oauth://callback/',
      // customUriScheme: 'com.tagref.oauth',
    );

    final response = await twitterLogin.loginV2();

    return response;
  }

  /// Look up the reverse chronological home timeline for the user and
  /// retrieve all images in its url form, includes retweets, excludes replies
  ///
  /// Returns a list of string containing image urls
  Future<List<String>> lookupHomeTimelineImages() async {
    List<String> imageUrls = [];

    // Query for home timeline
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
