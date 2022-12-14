import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tagref/helpers/google_api_helper.dart';

var db;

class DBHelper {
  static const String dbFileName = "tagref_db.db";

  static Future insertImage(String path, bool fromNetwork, {GoogleApiHelper? googleApiHelper}) async {
    var insertResult = await DBHelper.rawInsertAndPush(
        "INSERT INTO images (src_url, src_id) VALUES (?, ?)", [path, fromNetwork ? 1 : 2], googleApiHelper: googleApiHelper);

    return insertResult;
  }

  static initializeDatabase() async {
    var databaseFactory = databaseFactoryFfi;
    db = await databaseFactory.openDatabase(await getDBUrl());
  }

  static rawInsertAndPush(String insert, List options, {GoogleApiHelper? googleApiHelper}) async {
    await db.rawInsert(insert, options);

    if (googleApiHelper != null) await googleApiHelper.pushDB();
  }

  static rawDeleteAndPush(String delete, List options, {GoogleApiHelper? googleApiHelper}) async {
    await db.rawDelete(delete, options);

    if (googleApiHelper != null) await googleApiHelper.pushDB();
  }

  static Future<String> getDBUrl() async {
    Directory dbDir = await getApplicationSupportDirectory();
    return join(
      dbDir.path,
      dbFileName
    );
  }

  static Future<void> createDBWithTemplate() async {
    await db.execute('''
      CREATE TABLE images
      (
          img_id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          src_url        TEXT,
          src_id         TEXT
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

    await db
        .rawInsert("INSERT INTO sources (name) VALUES ('web'), ('local');");
  }
}
