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
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:system_tray/system_tray.dart' as tray;
import 'package:tagref/helpers/google_api_helper.dart';
import 'package:tagref/screen/home_screen_desktop.dart';
import 'package:tagref/screen/setup_screen.dart';

import 'assets/constant.dart';
import 'assets/db_helper.dart';

/// Should include all pre-start initializations here
void main(List<String> args) async {
  // Initialize libraries
  sqfliteFfiInit();

  if (runWebViewTitleBarWidget(args)) return;

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize environment variables
  const secureStorage = FlutterSecureStorage();
  final GoogleApiHelper gApiHelper;
  SharedPreferences pref = await SharedPreferences.getInstance();
  gApiHelper = GoogleApiHelper(
      secureStorage: secureStorage,
      localDBPath: (await getApplicationSupportDirectory()).path,
      dbFileName: DBHelper.dbFileName);

  if (pref.getBool(gDriveConnected) != null) {
    await gApiHelper.initializeAuthClient();
    await gApiHelper.initializeGoogleApi();
    await gApiHelper.updateLocalDB(true);
  }

  // Platform checks
  if (Platform.isWindows || Platform.isMacOS) {
    connectTagRefInstance(gApiHelper);
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

/// Open the current instance if it exists, if not, start a new instance
/// and bind to tagref ServerSocket port (33728/33729)
Future<void> connectTagRefInstance(GoogleApiHelper gApiHelper) async {
  bool lockSuccess = await lockInstance();
  for (int port in [33728, 33729]) {
    try {
      await startTagRefServer(gApiHelper, port: port);
    } catch (e) {
      if (!lockSuccess) {
        log(e.toString());
        (await Socket.connect("localhost", port)).write("T3BlbiBTZXNhbWU");
        appWindow.close();
      }
    }
  }
}

Future<void> startTagRefServer(GoogleApiHelper googleApiHelper,
    {int port = 33728}) async {
  final server = await ServerSocket.bind("localhost", port);

  server.listen((event) {
    log("Connection from ${event.address}");
    event.listen((data) {
      String plain = String.fromCharCodes(data);
      if (plain == "T3BlbiBTZXNhbWU") {
        appWindow.show();
      }

      String url = plain
          .substring(plain.indexOf("aWxvdmV0YWdyZWY"))
          .replaceAll("aWxvdmV0YWdyZWY", "");
      log(url);

      DBHelper.insertImage(url, true, googleApiHelper: googleApiHelper);
    });
  });
}

Future<bool> lockInstance() async {
  File lockFile =
      File(join((await getApplicationSupportDirectory()).path, "tagref.lock"));

  if (lockFile.existsSync()) {
    return false;
  } else {
    lockFile.createSync();
    return true;
  }
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
  bool routeInitialized = false;

  @override
  Widget build(BuildContext context) {
    if (!routeInitialized){
      initRoute().then((screen) => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => screen)));

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
      tray.MenuItemLable(
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

  Future<Widget> initRoute() async {
    String dbUrl = await DBHelper.getDBUrl();
    bool dbExists = await File(dbUrl).exists();
    log("Database already existed: " + dbExists.toString());

    // Initialize database when exists, create while not
    await DBHelper.initializeDatabase();

    if (!dbExists) {
      await DBHelper.createDBWithTemplate();

      return SetupScreen(gApiHelper: widget.gApiHelper);
    }


    return HomeScreen(
      gApiHelper: widget.gApiHelper,
    );
  }
}
