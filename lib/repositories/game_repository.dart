import 'dart:math';
import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/category.dart';
import '../models/word_item.dart';

class GameRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  // Obtener todas las categorías
  Future<List<Category>> getCategories() async {
    final db = await _db;
    final result = await db.query('categories', orderBy: 'id ASC');
    return result.map((e) => Category.fromMap(e)).toList();
  }

  // Actualizar si una categoría está activa o no
  Future<void> updateCategoryEnabled(int id, bool enabled) async {
    final db = await _db;
    await db.update(
      'categories',
      {'enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener todas las palabras de una categoría
  Future<List<WordItem>> getWordsByCategory(int categoryId) async {
    final db = await _db;
    final result = await db.query(
      'words',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return result.map((e) => WordItem.fromMap(e)).toList();
  }

  // Añadir palabra a la categoría personalizada
  Future<void> addCustomWord(String text) async {
    final db = await _db;

    final customCategory = await db.query(
      'categories',
      where: 'is_custom = 1',
      limit: 1,
    );

    if (customCategory.isEmpty) return;

    final categoryId = customCategory.first['id'] as int;

    await db.insert('words', {
      'text': text,
      'category_id': categoryId,
    });
  }

  // Borrar palabra por id
  Future<void> deleteWord(int id) async {
    final db = await _db;
    await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  // Palabra aleatoria de categorías activas
  Future<WordItem?> getRandomWordFromEnabledCategories() async {
    final db = await _db;

    final result = await db.rawQuery('''
      SELECT w.id, w.text, w.category_id
      FROM words w
      JOIN categories c ON c.id = w.category_id
      WHERE c.enabled = 1
      ORDER BY RANDOM()
      LIMIT 1;
    ''');

    if (result.isEmpty) return null;
    return WordItem.fromMap(result.first);
  }

  // Índice del impostor (entre 0 y playerCount - 1)
  int getRandomImpostorIndex(int playerCount) {
    final random = Random();
    return random.nextInt(playerCount);
  }
}
