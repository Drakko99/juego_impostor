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
  int _playerCount = 4;
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
          SnackBar(
            content: const Text('Activa al menos una categoría antes de jugar.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.privacy_tip, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Juego del Impostor'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card para selector de jugadores
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.groups, color: Colors.red.shade700, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Número de jugadores',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _playerCount > 3 
                                ? Colors.red.shade700.withOpacity(0.2)
                                : Colors.grey.shade800.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _playerCount > 3 ? _decreasePlayers : null,
                              icon: const Icon(Icons.remove),
                              iconSize: 32,
                              color: _playerCount > 3 ? Colors.red.shade700 : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade700, width: 2),
                            ),
                            child: Text(
                              '$_playerCount',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          Container(
                            decoration: BoxDecoration(
                              color: _playerCount < 12
                                ? Colors.red.shade700.withOpacity(0.2)
                                : Colors.grey.shade800.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _playerCount < 12 ? _increasePlayers : null,
                              icon: const Icon(Icons.add),
                              iconSize: 32,
                              color: _playerCount < 12 ? Colors.red.shade700 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '(3-12 jugadores)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Título de nombres
              Row(
                children: [
                  Icon(Icons.person, color: Colors.red.shade700, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Nombres de los jugadores',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Lista de jugadores
              Expanded(
                child: ListView.builder(
                  itemCount: _playerCount,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                        controller: _nameControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Jugador ${index + 1}',
                          prefixIcon: Icon(
                            Icons.account_circle,
                            color: Colors.red.shade700.withOpacity(0.7),
                          ),
                          hintText: 'Nombre opcional',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Botones
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Comenzar Partida',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _openCategories,
                      icon: const Icon(Icons.category, size: 24),
                      label: const Text(
                        'Categorías',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}