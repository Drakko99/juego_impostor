import 'dart:math';

import 'package:flutter/material.dart';

import '../repositories/game_repository.dart';
import '../models/word_item.dart';

class GameScreen extends StatefulWidget {
  final List<String> playerNames;

  const GameScreen({super.key, required this.playerNames});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameRepository _repo = GameRepository();

  WordItem? _secretWord;
  int? _impostorIndex;
  int _currentPlayer = 0;
  bool _revealed = false;
  bool _loading = true;
  String? _error;
  int? _startingPlayerIndex;
  int get _playerCount => widget.playerNames.length;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  Future<void> _startGame() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final word = await _repo.getRandomWordFromEnabledCategories();

    if (word == null) {
      setState(() {
        _loading = false;
        _error =
            'No hay palabras disponibles. Activa categorías o añade palabras personalizadas.';
      });
      return;
    }

    final impostorIndex = _repo.getRandomImpostorIndex(_playerCount);

    setState(() {
      _secretWord = word;
      _impostorIndex = impostorIndex;
      _currentPlayer = 0;
      _revealed = false;
      _loading = false;
    });
  }

  int _chooseStartingPlayerIndex() {
    if (_impostorIndex == null) {
      return Random().nextInt(_playerCount);
    }

    const double impostorWeight = 0.25;
    const double normalWeight = 1.0;

    final random = Random();
    final totalWeight =
        impostorWeight + (_playerCount - 1) * normalWeight;

    double r = random.nextDouble() * totalWeight;
    double acc = 0.0;

    for (int i = 0; i < _playerCount; i++) {
      final w = (i == _impostorIndex) ? impostorWeight : normalWeight;
      acc += w;
      if (r <= acc) {
        return i;
      }
    }
    return 0;
  }

  void _nextPlayer() {
    if (_currentPlayer < _playerCount - 1) {
      setState(() {
        _currentPlayer++;
        _revealed = false;
      });
    } else {
      final startingIndex = _chooseStartingPlayerIndex();

      setState(() {
        _startingPlayerIndex = startingIndex;
      });

      final starterName = widget.playerNames[startingIndex];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Listo!'),
          content: Text(
            'Todos los jugadores han visto su rol.\n\n'
            'Empieza: $starterName.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Partida')),
        body: Center(child: Text(_error!)),
      );
    }

    final isImpostor = _currentPlayer == _impostorIndex;
    final currentName = widget.playerNames[_currentPlayer];

    return Scaffold(
      appBar: AppBar(title: const Text('Partida')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                currentName,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!_revealed)
                FilledButton(
                  onPressed: () {
                    setState(() => _revealed = true);
                  },
                  child: const Text('Ver tu palabra / rol'),
                )
              else ...[
                Text(
                  isImpostor ? 'ERES EL IMPOSOR' : _secretWord!.text,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _nextPlayer,
                  child: Text(
                    _currentPlayer == _playerCount - 1
                        ? 'Terminar'
                        : 'Siguiente jugador',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}