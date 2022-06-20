import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tagref/screen/HomeScreen.dart';
import 'package:tagref/screen/SetupScreen.dart';

import 'assets/DBHelper.dart';
import 'firebase_options.dart';

void main() async {
  sqfliteFfiInit();

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // TODO: Create driveApi var if user has logged in before

  // Initialize firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

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
      designSize: const Size(1280, 720),
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

    await DBHelper.initializeDatabase();

    if (!dbExists) {
      await DBHelper.db.execute('''
      CREATE TABLE images
      (
          img_id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          src_url        TEXT,
          src_id         INTEGER,
          FOREIGN KEY (src_id) REFERENCES sources (src_id)
      );
      CREATE TABLE sources
      (
          src_id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name           TEXT
      );
      CREATE TABLE tags
      (
          tag_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name   varchar
      );
      CREATE TABLE pins
      (
          pin_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          img_id int,
          FOREIGN KEY (img_id) REFERENCES images (img_id)
      );
      CREATE TABLE image_tag
      (
          id     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          img_id int,
          tag_id int,
          FOREIGN KEY (img_id) REFERENCES images (img_id),
          FOREIGN KEY (tag_id) REFERENCES tags (tag_id)
      );
      ''');

      await DBHelper.db
          .rawInsert("INSERT INTO sources (name) VALUES ('web'), ('local');");
      return const SetupScreen();
    }

    return const HomeScreen();
  }
}
