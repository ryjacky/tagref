import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/screen/home_screen.dart';
import 'package:tagref/screen/home_screen_desktop.dart';
import 'package:tagref/screen/setup_screen.dart';

import 'assets/constant.dart';
import 'assets/db_helper.dart';

/// Should include all pre-start initializations here
void main(List<String> args) async {
  const secureStorage = FlutterSecureStorage();
  final GoogleApiHelper gApiHelper;

  sqfliteFfiInit();

  if (runWebViewTitleBarWidget(args)) {
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initializes DriveApi and update local DB file
  gApiHelper = GoogleApiHelper(
      secureStorage: secureStorage,
      localDBPath: (await getApplicationSupportDirectory()).path,
      dbFileName: DBHelper.dbFileName);
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.getBool(gDriveConnected) != null) {
    await gApiHelper.initializeGoogleApi();

    // Sync database
    await gApiHelper.syncDB();
  }

  runApp(EasyLocalization(
      child: MyApp(
        gApiHelper: gApiHelper,
        secureStorage: secureStorage,
      ),
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ja')],
      path: 'assets/translations'));

  doWhenWindowReady(() {
    const initialSize = Size(1280, 720);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage secureStorage;
  final GoogleApiHelper gApiHelper;

  const MyApp({Key? key, required this.secureStorage, required this.gApiHelper})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:
          Platform.isAndroid ? const Size(720, 1280) : const Size(1280, 720),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ScreenRouter(
        title: 'TagRef Home',
        secureStorage: secureStorage,
        gApiHelper: gApiHelper,
      ),
      builder: (context, child) {
        return MaterialApp(
          title: 'TagRef',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
              textTheme: const TextTheme(
                  titleLarge: TextStyle(
                    fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 46),
                  titleSmall: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30),
                  labelMedium: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                      color: Colors.white),
                  labelLarge: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                  labelSmall: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  bodySmall: TextStyle(color: Colors.white60, fontSize: 18),
                  bodyMedium: TextStyle(color: Colors.white60, fontSize: 2),
                  titleMedium: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30),
                  headlineSmall: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 20),
                  headlineMedium: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontSize: 28)),
              primarySwatch: Colors.purple),
          home: child,
        );
      },
    );
  }
}

class ScreenRouter extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  final GoogleApiHelper gApiHelper;

  const ScreenRouter(
      {Key? key,
      required this.title,
      required this.secureStorage,
      required this.gApiHelper})
      : super(key: key);
  final String title;

  @override
  State<ScreenRouter> createState() => _ScreenRouterState();
}

class _ScreenRouterState extends State<ScreenRouter> {
  bool syncing = false;
  @override
  Widget build(BuildContext context) {
    initRoute().then((screen) => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => screen)));
    return const Scaffold();
  }

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 5), (timer) { 
      if (!syncing){
        // Detects remote changes
        syncing = true;
        widget.gApiHelper.syncDB().then((value) => syncing = false);
      }
    });
  }

  Future<Widget> initRoute() async {
    String dbUrl = await DBHelper.getDBUrl();
    bool dbExists = await File(dbUrl).exists();

    // Initialize database when exists, create while not
    await DBHelper.initializeDatabase();

    if (!dbExists) {
      await DBHelper.createDBWithTemplate();
      return SetupScreen(gApiHelper: widget.gApiHelper);
    }

    return (Platform.isWindows || Platform.isMacOS)
        ? HomeScreenDesktop(
            gApiHelper: widget.gApiHelper,
          )
        : HomeScreen(gApiHelper: widget.gApiHelper);
  }
}
