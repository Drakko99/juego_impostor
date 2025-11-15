import 'package:flutter/material.dart';

import '../repositories/game_repository.dart';
import '../models/category.dart';
import 'game_screen.dart';
import 'custom_words_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameRepository _repo = GameRepository();
  List<Category> _categories = [];
  bool _loading = true;
  int _playerCount = 4;

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

  void _startGame() {
    if (_categories.where((c) => c.enabled).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activa al menos una categoría.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerCount: _playerCount),
      ),
    );
  }

  void _openCustomWords() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => const CustomWordsScreen(),
          ),
        )
        .then((_) => _loadCategories()); // por si cambias algo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego del Impostor'),
        actions: [
          IconButton(
            onPressed: _openCustomWords,
            icon: const Icon(Icons.edit),
            tooltip: 'Palabras personalizadas',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'Número de jugadores: $_playerCount',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _playerCount.toDouble(),
                  min: 3,
                  max: 12,
                  divisions: 9,
                  label: '$_playerCount',
                  onChanged: (value) {
                    setState(() {
                      _playerCount = value.toInt();
                    });
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final c = _categories[index];
                      return SwitchListTile(
                        title: Text(c.name),
                        value: c.enabled,
                        onChanged: (val) => _toggleCategory(c, val),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _startGame,
                      child: const Text('Comenzar partida'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
