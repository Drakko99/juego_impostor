import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../repositories/game_repository.dart';
import '../models/word_item.dart';

class CustomWordsScreen extends StatefulWidget {
  const CustomWordsScreen({super.key});

  @override
  State<CustomWordsScreen> createState() => _CustomWordsScreenState();
}

class _CustomWordsScreenState extends State<CustomWordsScreen> {
  final GameRepository _repo = GameRepository();
  final TextEditingController _controller = TextEditingController();

  List<WordItem> _words = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomWords();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<int?> _getCustomCategoryId() async {
    final Database db = await AppDatabase.instance.database;
    final res = await db.query(
      'categories',
      where: 'is_custom = 1',
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first['id'] as int;
  }

  Future<void> _loadCustomWords() async {
    setState(() => _loading = true);

    final customCategoryId = await _getCustomCategoryId();
    if (customCategoryId == null) {
      setState(() {
        _words = [];
        _loading = false;
      });
      return;
    }

    final Database db = await AppDatabase.instance.database;
    final result = await db.query(
      'words',
      where: 'category_id = ?',
      whereArgs: [customCategoryId],
      orderBy: 'id DESC',
    );

    setState(() {
      _words = result.map((e) => WordItem.fromMap(e)).toList();
      _loading = false;
    });
  }

  Future<void> _addWord() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _repo.addCustomWord(text);
    _controller.clear();
    await _loadCustomWords();
  }

  Future<void> _deleteWord(int id) async {
    await _repo.deleteWord(id);
    await _loadCustomWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Palabras personalizadas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nueva palabra',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addWord(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addWord,
                  child: const Text('Añadir'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _words.isEmpty
                    ? const Center(
                        child: Text('No hay palabras personalizadas todavía.'),
                      )
                    : ListView.builder(
                        itemCount: _words.length,
                        itemBuilder: (context, index) {
                          final word = _words[index];
                          return ListTile(
                            title: Text(word.text),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteWord(word.id!),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
