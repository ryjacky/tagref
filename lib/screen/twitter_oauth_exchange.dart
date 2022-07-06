import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
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
  final String callback = "https://com.tagref.app/twitter/oauth";

  // final String callback = "tagref://twitter/oauth";

  late final String authURI;

  bool winWebViewShown = false;

  @override
  void initState() {
    super.initState();
    authURI =
    "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=$clientId&redirect_uri=$callback&scope=tweet.read%20users.read%20follows.read&state=state&code_challenge=challenge&code_challenge_method=plain";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (Platform.isAndroid || Platform.isIOS)
          ? getMobileWebView()
          : getDesktopWebView(),
    );
  }

  void launchWindowsWebView() async {
    if (!winWebViewShown) {
      winWebViewShown = true;

      final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          windowHeight: 700,
          windowWidth: 400,
          titleBarHeight: 0,
          titleBarTopPadding: Platform.isMacOS ? 0 : 0,
          title: "Twitter Authorization"
          // userDataFolderWindows: await _getWebViewPath(),
        ),
      );

      webview.launch(authURI);
      webview.addOnUrlRequestCallback((url) {
        if (url.startsWith(callback)) {
          Uri callbackUri = Uri.parse(url);
          String? authCode = callbackUri.queryParameters["code"];

          if (authCode == null) {
            throw Exception("The end point returned an unknown result.");
          }

          log(
              "WebView has returned the auth code, exchanging for access token...");
          log("auth code: $authCode");
          exchangeForAccessToken(authCode).then((acecssToken) {
            webview.close();
            Navigator.pop(context, acecssToken);
          });
        }
      });
    }
  }

  Widget getDesktopWebView() {
    launchWindowsWebView();
    return Text("Please complete the login process in the popup.");
  }

  WebView getMobileWebView() {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: authURI,
      navigationDelegate: (navReq) {
        if (navReq.url.startsWith(callback)) {
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
      'redirect_uri': callback,
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
