import 'package:flutter/material.dart';

import '../repositories/game_repository.dart';
import '../models/category.dart';
import 'custom_words_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final GameRepository _repo = GameRepository();
  List<Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _repo.getCategories();
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  Future<void> _toggleCategory(Category cat, bool value) async {
    await _repo.updateCategoryEnabled(cat.id!, value);
    await _loadCategories();
  }

  void _openCustomWords() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => const CustomWordsScreen(),
          ),
        )
        .then((_) => _loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final c = _categories[index];

                if (!c.isCustom) {
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Text(c.name),
                    trailing: Switch(
                      value: c.enabled,
                      onChanged: (val) => _toggleCategory(c, val),
                    ),
                  );
                }

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.name),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Añadir palabras personalizadas',
                        onPressed: _openCustomWords,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  trailing: Switch(
                    value: c.enabled,
                    onChanged: (val) => _toggleCategory(c, val),
                  ),
                );
              },
            ),
    );
  }
}