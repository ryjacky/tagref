import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/helpers/twitter_api_helper.dart';
import 'package:tagref/screen/home_screen.dart';
import 'package:tagref/screen/setup_screen.dart';
import 'package:tagref/screen/twitter_oauth_exchange.dart';

import 'assets/db_helper.dart';
import 'assets/constant.dart';

/// Should include all pre-start initializations here
void main() async {
  sqfliteFfiInit();

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initializes DriveApi and update local DB file
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.getBool(gDriveConnected) != null) {
    await initializeDriveApiAndPullDB(
        (await getApplicationSupportDirectory()).path, DBHelper.dbFileName);
  }

  runApp(EasyLocalization(
      child: const MyApp(),
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ja')],
      path: 'assets/translations'));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:
          Platform.isAndroid ? const Size(720, 1280) : const Size(1280, 720),
      minTextAdapt: true,
      splitScreenMode: true,
      child: const TagRefHome(title: 'TagRef Home'),
      builder: (context, child) {
        return MaterialApp(
          title: 'TagRef',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(primarySwatch: Colors.purple),
          home: child,
        );
      },
    );
  }
}

class TagRefHome extends StatefulWidget {
  const TagRefHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<TagRefHome> createState() => _TagRefHomePageState();
}

class _TagRefHomePageState extends State<TagRefHome> {
  @override
  Widget build(BuildContext context) {
    initRoute().then((screen) => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => screen)));
    return const Scaffold();
  }

  Future<Widget> initRoute() async {
    String dbUrl = await DBHelper.getDBUrl();
    bool dbExists = await File(dbUrl).exists();

    // Initialize database when exists, create while not
    await DBHelper.initializeDatabase();

    if (!dbExists) {
      await DBHelper.createDBWithTemplate();
      return const SetupScreen();
    }

    return const HomeScreen();
  }
}
