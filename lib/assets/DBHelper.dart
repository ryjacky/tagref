import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static var db;
  static const String dbFileName = "tagref_db.db";

  static initializeDatabase() async {
    var databaseFactory = databaseFactoryFfi;
    db = await databaseFactory.openDatabase(await getDBUrl());
  }

  static Future<String> getDBUrl() async {
    Directory dbDir = await getApplicationSupportDirectory();
    return join(
      dbDir.path,
      dbFileName
    );
  }
}
