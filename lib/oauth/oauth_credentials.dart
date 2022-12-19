class OAuthCredentials {
  late String accessToken;
  late String refreshToken;

  OAuthCredentials({required this.accessToken, required this.refreshToken});

  OAuthCredentials.fromMap(Map<String, String> credentials){
    if (!credentials.containsKey("access_token") || !credentials.containsKey("refresh_token")){
      throw Exception("Given map does not contain required keys");
    }

    accessToken = credentials["access_token"]!;
    refreshToken = credentials["refresh_token"]!;
  }
}