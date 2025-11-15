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
    final enabledCount = _categories.where((c) => c.enabled).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: enabledCount > 0 
                    ? Colors.green.shade700.withOpacity(0.3)
                    : Colors.red.shade700.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: enabledCount > 0 ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                child: Text(
                  '$enabledCount activas',
                  style: TextStyle(
                    color: enabledCount > 0 ? Colors.green.shade300 : Colors.red.shade300,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade700),
                      const SizedBox(height: 16),
                      Text(
                        'No hay categorías disponibles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final c = _categories[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        elevation: c.enabled ? 6 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: c.enabled 
                              ? Colors.red.shade700.withOpacity(0.5)
                              : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8.0,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: c.enabled 
                                ? Colors.red.shade700.withOpacity(0.2)
                                : Colors.grey.shade800.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              c.isCustom ? Icons.edit : Icons.category,
                              color: c.enabled ? Colors.red.shade700 : Colors.grey,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: c.enabled ? Colors.white : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (c.isCustom)
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.red.shade700,
                                  ),
                                  tooltip: 'Añadir palabras',
                                  onPressed: _openCustomWords,
                                ),
                              Switch(
                                value: c.enabled,
                                onChanged: (val) => _toggleCategory(c, val),
                                activeColor: Colors.red.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}