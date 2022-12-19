class OAuthCredentials {
  final String accessToken;
  final String refreshToken;
  final DateTime expires;

  OAuthCredentials({required this.accessToken, required this.refreshToken, required this.expires});
}