import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:webview_flutter/webview_flutter.dart';

class TwitterApiHelper {
  late final TwitterApi twitterClient;

  late final String userId;
  final FlutterSecureStorage secureStorage;

  final tTokenSSKey = "com.tagref.twitterUserToken";
  final uidSSKey = "com.tagref.twitterUserId";

  TwitterApiHelper({required this.secureStorage}) {
    authTwitterMobile();

    secureStorage.read(key: uidSSKey).then((uid) {
      secureStorage.read(key: tTokenSSKey).then((tToken) {
        if (tToken != null && uid != null) {
          userId = uid;
          twitterClient = TwitterApi(bearerToken: tToken);
        } else {
          authTwitterMobile();
          // authTwitterMobile().then((response) {
          //   twitterClient = TwitterApi(
          //     bearerToken: response.authToken!,
          //
          //     //! The default timeout is 10 seconds.
          //     timeout: const Duration(seconds: 20),
          //   );
          //
          //   twitterClient.usersService.lookupMe().then((myData) {
          //     userId = myData.data.id;
          //
          //     secureStorage.write(
          //         key: tTokenSSKey, value: response.authToken);
          //     secureStorage.write(key: uidSSKey, value: userId);
          //   });
          // });
        }
      });
    });
  }

  Future<void> authTwitterMobile() async {
    print(await launchUrl(
        Uri.parse("https://twitter.com/i/oauth2/authorize?response_type=code&client_id=emVVNlIxSDdnOWlnNzI2bTJUdVE6MTpjaQ&redirect_uri=com.tagref.oauth://callback/&scope=tweet.read%20users.read%20follows.read%20offline.access&state=state&code_challenge=challenge&code_challenge_method=plain"),
    ));

    WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl:         "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=emVVNlIxSDdnOWlnNzI2bTJUdVE6MTpjaQ&redirect_uri=com.tagref.oauth://callback/&scope=tweet.read%20users.read%20follows.read%20offline.access&state=state&code_challenge=challenge&code_challenge_method=plain",
      navigationDelegate: (navReq) {
        if (navReq.url.startsWith("com.tagref.oauth://callback/")) {
          Uri.parse(navReq.url);
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      // ------- 8< -------
    );
    // DUFbAjOMGIDq57gZ54nGw1N4IwIJhHRHARxY5T0d_LWbwVwXty
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
