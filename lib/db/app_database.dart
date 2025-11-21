import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'impostor_game.db');

    return openDatabase(
      path,
      version: 2, // Incrementamos la versión
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialDataFromJson(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Añadir columna is_adult a la tabla existente
          await db.execute('ALTER TABLE categories ADD COLUMN is_adult INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Tabla categorías
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        is_custom INTEGER NOT NULL DEFAULT 0,
        is_adult INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // Tabla palabras
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      );
    ''');
  }

  /// Lee assets/data/words.json y rellena categorías + palabras.
  Future<void> _seedInitialDataFromJson(Database db) async {
    // Leemos el archivo JSON
    final jsonString = await rootBundle.loadString('assets/data/words.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    final List<dynamic> categories = data['categories'] as List<dynamic>;

    // Usamos una transacción para que sea más rápido y seguro
    await db.transaction((txn) async {
      for (final dynamic cat in categories) {
        final Map<String, dynamic> catMap = cat as Map<String, dynamic>;
        final String name = catMap['name'] as String;
        final bool isCustom = catMap['is_custom'] as bool? ?? false;
        final bool isAdult = catMap['is_adult'] as bool? ?? false;
        final List<dynamic> words = catMap['words'] as List<dynamic>? ?? [];

        // Insertamos categoría
        final int categoryId = await txn.insert('categories', {
          'name': name,
          'enabled': isAdult ? 0 : 1, // Las categorías +18 se crean desactivadas
          'is_custom': isCustom ? 1 : 0,
          'is_adult': isAdult ? 1 : 0,
        });

        // Insertamos palabras de esa categoría
        for (final dynamic w in words) {
          final String text = w.toString().trim();
          if (text.isEmpty) continue;

          await txn.insert('words', {
            'text': text,
            'category_id': categoryId,
          });
        }
      }
    });
  }
}