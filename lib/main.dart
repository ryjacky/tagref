import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagref/screen/HomeScreen.dart';
import 'package:tagref/screen/SetupScreen.dart';

import 'assets/constant.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
      child: const MyApp(),
      fallbackLocale: Locale('en'),
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
    final prefs = await SharedPreferences.getInstance();
    if (prefs.get(Preferences.language) == null) {
      return const SetupScreen();
    }

    return const HomeScreen();
  }
}
