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

  int _playerCount = 4; // número de jugadores (3–12)

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
        .then((_) => _loadCategories());
  }

  void _increasePlayers() {
    setState(() {
      if (_playerCount < 12) {
        _playerCount++;
      }
    });
  }

  void _decreasePlayers() {
    setState(() {
      if (_playerCount > 3) {
        _playerCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego del Impostor'),
        // Ya no hay icono de editar aquí, el botón va junto a "Personalizada"
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 24),

                // 🔢 Selector de número de jugadores (grande + botones +/-)
                Text(
                  'Número de jugadores',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _decreasePlayers,
                      icon: const Icon(Icons.remove),
                      iconSize: 32,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$_playerCount',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _increasePlayers,
                      icon: const Icon(Icons.add),
                      iconSize: 32,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                // Lista de categorías
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final c = _categories[index];

                      // Categorías normales 
                      if (!c.isCustom) {
                        return SwitchListTile(
                          title: Text(c.name),
                          value: c.enabled,
                          onChanged: (val) => _toggleCategory(c, val),
                        );
                      }

                      // Categoría personalizada
                      return ListTile(
                        title: Row(
                          children: [
                            // Texto "Personalizada"
                            Text(c.name),

                            const SizedBox(width: 8),

                            // Botón "+" junto al texto
                            IconButton(
                              icon: const Icon(Icons.add),
                              tooltip: 'Añadir palabras personalizadas',
                              onPressed: _openCustomWords,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(), // para que no ocupe demasiado
                            ),

                            const Spacer(),

                            // Switch a la derecha, como en el resto de categorías
                            Switch(
                              value: c.enabled,
                              onChanged: (val) => _toggleCategory(c, val),
                            ),
                          ],
                        ),
                        // Opcional: para que la tile sea un poco más compacta
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      );
                    },
                  ),
                ),

                // Botón para empezar partida
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
