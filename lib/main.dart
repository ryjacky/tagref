import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart' as tray;
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/server/BrowserExServer.dart';
import 'package:tagref/ui/screen/home_screen_desktop.dart';
import 'package:tagref/ui/screen/setup_screen.dart';

import 'assets/constant.dart';
import 'isar/IsarHelper.dart';

late final IsarHelper _isarHelper;
late final SharedPreferences _pref;

/// Should include all pre-start initializations here
void main(List<String> args) async {
  // Initialize database
  _isarHelper = IsarHelper();
  _isarHelper.openDB();

  // Initialize webview
  if (runWebViewTitleBarWidget(args)) return;

  // Initialize localization
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize environment variables
  const secureStorage = FlutterSecureStorage();

  // Initialize shared preferences
  _pref = await SharedPreferences.getInstance();
  _pref.setBool(Preferences.initialized, _pref.getBool(Preferences.initialized) ?? false);
  _pref.setString(Preferences.language, _pref.getString(Preferences.language) ?? locale[0]);

  // Initialize google api
  final GoogleApiHelper gApiHelper;
  gApiHelper = GoogleApiHelper(
      secureStorage: secureStorage,
      localDBPath: (await getApplicationSupportDirectory()).path,
      dbFileName: await _isarHelper.getDBUrl());

  if (_pref.getBool(gDriveConnected) != null) {
    await gApiHelper.initializeAuthClient();
    await gApiHelper.initializeGoogleApi();
    await gApiHelper.updateLocalDB(true);
  }

  // Starts tagref server when running on windows/macos
  if (Platform.isWindows || Platform.isMacOS) {
    ExtensionServer(_isarHelper).connectTagRefInstance(gApiHelper);
  }

  runApp(EasyLocalization(
      child: TagRefUIRoot(
        gApiHelper: gApiHelper,
        secureStorage: secureStorage,
      ),
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ja')],
      path: 'assets/translations'));
}


class TagRefUIRoot extends StatelessWidget {
  final FlutterSecureStorage secureStorage;
  final GoogleApiHelper gApiHelper;

  const TagRefUIRoot(
      {Key? key, required this.secureStorage, required this.gApiHelper})
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
                  bodyMedium: TextStyle(color: Colors.white60, fontSize: 22),
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
              primarySwatch: Colors.purple,
              primaryColor: desktopColorDark,
              primaryColorLight: desktopColorLight
          ),
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
  bool routeInitialized = false;

  @override
  Widget build(BuildContext context) {
    if (!routeInitialized){
      Widget initialRoute = initRoute();
      Future.delayed(const Duration(seconds: 1), (){
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => initialRoute));
      });

      routeInitialized = true;
    }

    return const Scaffold();
  }

  @override
  void initState() {
    super.initState();

    // Initialize or override system UI components
    if (Platform.isWindows || Platform.isMacOS) {
      initSystemTray();

      doWhenWindowReady(() {
        const initialSize = Size(900, 600);
        appWindow.minSize = initialSize;
        appWindow.alignment = Alignment.center;
        appWindow.show();
      });
    }

    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!syncing) {
        // Detects remote changes
        syncing = true;
        if (widget.gApiHelper.isInitialized) {
          widget.gApiHelper.updateLocalDB(true).then((value) => syncing = false);
        }
      }
    });
  }

  Future<void> initSystemTray() async {
    String path = Platform.isWindows
        ? 'assets/images/logo.ico'
        : 'assets/images/logo.png';

    final tray.AppWindow _appWindow = tray.AppWindow();
    final tray.SystemTray systemTray = tray.SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "",
      iconPath: path,
    );

    // create context menu
    final tray.Menu menu = tray.Menu();
    await menu.buildFrom([
      tray.MenuItemLabel(
          label: 'Exit', onClicked: (menuItem) => exitApplication(_appWindow)),
    ]);

    // set context menu
    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == tray.kSystemTrayEventClick) {
        Platform.isWindows ? _appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == tray.kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : _appWindow.show();
      }
    });
  }

  void exitApplication(tray.AppWindow appWindow) async {
    File lockFile = File(
        join((await getApplicationSupportDirectory()).path, "tagref.lock"));

    await lockFile.delete();
    appWindow.close();
  }

  Widget initRoute() {
    if (_pref.getBool(Preferences.initialized) == null || _pref.getBool(Preferences.initialized) == false) {
      return SetupScreen(gApiHelper: widget.gApiHelper, isarHelper: _isarHelper, pref: _pref,);
    } else {
      log("Database exists, skipping setup page");
      return const HomeScreen();
    }

  }
}
