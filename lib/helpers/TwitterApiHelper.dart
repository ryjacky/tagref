import 'package:twitter_api_v2/twitter_api_v2.dart';

class TwitterApiHelper {
  final TwitterApi twitterClient = TwitterApi(
    // TODO: Change token
    bearerToken:
        'AAAAAAAAAAAAAAAAAAAAAIrkdAEAAAAA2lsF%2BGa7pDUOFxelcJssNv%2FwkDE%3DoZE4KjmSOxkqQZ73n7HkAOlNW83rSbFL3HxLxOgOe6EzWJz0tT',

    //! Or perhaps you would prefer to use the good old OAuth1.0a method
    //! over the OAuth2.0 PKCE method. Then you can use the following code
    //! to set the OAuth1.0a tokens.
    //!
    //! However, note that some endpoints cannot be used for OAuth 1.0a method
    //! authentication.
    oauthTokens: OAuthTokens(
      consumerKey: 'XVJd59U7iSFcYci4zJw3m2dj9',
      consumerSecret: 'WQiZScrcngnHz7csVgtTGGCWkIGfcxrpX8EiDOL5vuKeJGCPwl',
      accessToken: '1471331069781630976-13Lir0zhQQyNbFtWoOAGHxSgxtQXOO',
      accessTokenSecret: 'cAehjZglTTmUhe3JkmQjXQhNkZYGuAP4QHO74pHgITCgu',
    ),

    //! The default timeout is 10 seconds.
    timeout: Duration(seconds: 20),
  );

  late final String userId = "1471331069781630976";

  TwitterApiHelper() {
    print("slkdjf");
    // twitterClient
    //.usersService.lookupMe().then((user) => userId = user.data.id);
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
        .lookupHomeTimeline(userId: userId, excludes: [
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
