import 'dart:developer';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:tagref/isar/IsarHelper.dart';

import '../helpers/google_api_helper.dart';

class ExtensionServer{

  late final IsarHelper _isarHelper;

  ExtensionServer(IsarHelper isarHelper){
    _isarHelper = isarHelper;
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

  /// Open the current server instance if it exists, if not, start a new instance
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

        _isarHelper.putImage(url, googleApiHelper: googleApiHelper);
      });
    });
  }

}