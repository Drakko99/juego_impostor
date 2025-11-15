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
      version: 1,
      onCreate: (db, version) async {
        // Crear tabla de categorías
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            enabled INTEGER NOT NULL DEFAULT 1,
            is_custom INTEGER NOT NULL DEFAULT 0
          );
        ''');

        // Crear tabla de palabras
        await db.execute('''
          CREATE TABLE words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            category_id INTEGER NOT NULL,
            FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
          );
        ''');

        // Insertar categorías iniciales
        final comidaId = await db.insert('categories', {
          'name': 'Comida',
          'enabled': 1,
          'is_custom': 0,
        });

        final animalesId = await db.insert('categories', {
          'name': 'Animales',
          'enabled': 1,
          'is_custom': 0,
        });

        final peliculasId = await db.insert('categories', {
          'name': 'Películas',
          'enabled': 1,
          'is_custom': 0,
        });

        final personalizadaId = await db.insert('categories', {
          'name': 'Personalizada',
          'enabled': 1,
          'is_custom': 1,
        });

        // Palabras de ejemplo
        await db.insert('words', {
          'text': 'Pizza',
          'category_id': comidaId,
        });
        await db.insert('words', {
          'text': 'Hamburguesa',
          'category_id': comidaId,
        });
        await db.insert('words', {
          'text': 'Perro',
          'category_id': animalesId,
        });
        await db.insert('words', {
          'text': 'Gato',
          'category_id': animalesId,
        });
        await db.insert('words', {
          'text': 'Matrix',
          'category_id': peliculasId,
        });
        await db.insert('words', {
          'text': 'Titanic',
          'category_id': peliculasId,
        });

        // Por ahora la categoría personalizada empieza vacía
        personalizadaId; // solo para que no se queje el analizador
      },
    );
  }
}
