import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class TwitterOAuthExchange extends StatefulWidget {
  const TwitterOAuthExchange({Key? key}) : super(key: key);

  @override
  State<TwitterOAuthExchange> createState() => _TwitterOAuthExchangeState();
}

class _TwitterOAuthExchangeState extends State<TwitterOAuthExchange> {
  final String clientId = "emVVNlIxSDdnOWlnNzI2bTJUdVE6MTpjaQ";
  final String clientSecret =
      "DUFbAjOMGIDq57gZ54nGw1N4IwIJhHRHARxY5T0d_LWbwVwXty";
  final String callback = "tagref://twitter/oauth";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl:
            "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=$clientId&redirect_uri=$callback&scope=tweet.read%20users.read%20follows.read&state=state&code_challenge=challenge&code_challenge_method=plain",
        navigationDelegate: (navReq) {
          if (navReq.url.startsWith("tagref://twitter/oauth")) {
            Uri callbackUri = Uri.parse(navReq.url);
            String? authCode = callbackUri.queryParameters["code"];

            if (authCode == null) {
              throw Exception("The end point returned an unknown result.");
            }
            exchangeForAccessToken(authCode).then((acecssToken) {
              Navigator.pop(context, acecssToken);
            });
            // return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  Future<String> exchangeForAccessToken(String authCode) async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      // 'Authorization': 'Basic $clientSecret',
    };

    var data = {
      'code': authCode,
      'grant_type': 'authorization_code',
      'client_id': 'emVVNlIxSDdnOWlnNzI2bTJUdVE6MTpjaQ',
      'redirect_uri': 'tagref://twitter/oauth',
      'code_verifier': 'challenge',
    };

    var url = Uri.parse('https://api.twitter.com/2/oauth2/token');
    var res = await http.post(url, headers: headers, body: data);
    if (res.statusCode != 200) {
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    }

    return jsonDecode(res.body)["access_token"];
  }
}
