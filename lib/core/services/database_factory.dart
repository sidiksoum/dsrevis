import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initializeDatabaseFactory() async {
  if (!kIsWeb) return;

  try {
    // Use the web-specific sqflite factory to initialize the default global database
    // factory before any database calls are made on the web platform.
    databaseFactory = databaseFactoryFfiWeb;
  } catch (_) {
    // ignore failures during hot reload or if the web factory was already initialized.
  }
}
