import 'package:flutter/material.dart';

import '../repositories/game_repository.dart';
import 'game_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameRepository _repo = GameRepository();

  int _playerCount = 4; // mínimo 3, máximo 12
  final List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    _initNameControllers();
  }

  void _initNameControllers() {
    _nameControllers.clear();
    for (int i = 0; i < _playerCount; i++) {
      _nameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _increasePlayers() {
    setState(() {
      if (_playerCount < 12) {
        _playerCount++;
        _nameControllers.add(TextEditingController());
      }
    });
  }

  void _decreasePlayers() {
    setState(() {
      if (_playerCount > 3) {
        _playerCount--;
        final removed = _nameControllers.removeLast();
        removed.dispose();
      }
    });
  }

  void _openCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CategoriesScreen(),
      ),
    );
  }

  Future<void> _startGame() async {
    final categories = await _repo.getCategories();
    final hasEnabled = categories.any((c) => c.enabled);

    if (!hasEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activa al menos una categoría antes de jugar.'),
          ),
        );
      }
      return;
    }

    final List<String> playerNames = [];
    for (int i = 0; i < _playerCount; i++) {
      final text = _nameControllers[i].text.trim();
      if (text.isEmpty) {
        playerNames.add('Jugador ${i + 1}');
      } else {
        playerNames.add(text);
      }
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerNames: playerNames),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juego del Impostor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              'Número de jugadores',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
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
            Text(
              'Nombres de los jugadores',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _playerCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: _nameControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Jugador ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _openCategories,
                    child: const Text('Categorías'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _startGame,
                    child: const Text('Comenzar partida'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}