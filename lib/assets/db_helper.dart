import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tagref/helpers/google_api_helper.dart';

class DBHelper {
  static var db;
  static const String dbFileName = "tagref_db.db";

  static Future insertImage(String path, bool fromNetwork,
      {GoogleApiHelper? googleApiHelper}) async {
    var insertResult = await DBHelper.db.rawInsert(
        "INSERT INTO images (src_url, src_id) VALUES (?, ?)",
        [path, fromNetwork ? 1 : 2]);

    if (googleApiHelper != null) {
      googleApiHelper.pushDB();
    }

    return insertResult;
  }

  static Future<List<Map>> selectUndeleted(
      String tableName, String columnName, Map<String, String> where) async {

    String whereQueryString = "";
    for (String whereColumn in where.keys) {
      whereQueryString += whereColumn + "=? AND ";
    }
    whereQueryString += "deleted <> 1";

    String query = "SELECT $columnName FROM $tableName WHERE " + whereQueryString;
    log(query);

    return await db.rawQuery(query, where.values.toList());
  }

  static initializeDatabase() async {
    var databaseFactory = databaseFactoryFfi;
    db = await databaseFactory.openDatabase(await getDBUrl());
  }

  static Future<String> getDBUrl() async {
    Directory dbDir = await getApplicationSupportDirectory();
    return join(dbDir.path, dbFileName);
  }

  static Future<void> createDBWithTemplate() async {
    await DBHelper.db.execute('''
      CREATE TABLE images
      (
          img_id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          src_url        TEXT,
          src_id         INTEGER,
          deleted        INTEGER DEFAULT 0 NOT NULL,
          FOREIGN KEY (src_id) REFERENCES sources (src_id)
      );
      CREATE TABLE sources
      (
          src_id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name           TEXT,
          deleted        INTEGER DEFAULT 0 NOT NULL
      );
      CREATE TABLE tags
      (
          tag_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name           TEXT,
          deleted        INTEGER DEFAULT 0 NOT NULL
      );
      CREATE TABLE pins
      (
          pin_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          img_id         INTEGER,
          deleted        INTEGER DEFAULT 0 NOT NULL,
          FOREIGN KEY (img_id) REFERENCES images (img_id)
      );
      CREATE TABLE image_tag
      (
          id     INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          img_id         INTEGER,
          tag_id         INTEGER,
          deleted        INTEGER DEFAULT 0 NOT NULL,
          FOREIGN KEY (img_id) REFERENCES images (img_id),
          FOREIGN KEY (tag_id) REFERENCES tags (tag_id)
      );
      ''');

    await DBHelper.db
        .rawInsert("INSERT INTO sources (name) VALUES ('web'), ('local');");
  }
}
