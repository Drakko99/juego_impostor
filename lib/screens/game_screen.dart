import 'package:flutter/material.dart';

import '../repositories/game_repository.dart';
import '../models/word_item.dart';

class GameScreen extends StatefulWidget {
  final int playerCount;

  const GameScreen({super.key, required this.playerCount});

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

    final impostorIndex = _repo.getRandomImpostorIndex(widget.playerCount);

    setState(() {
      _secretWord = word;
      _impostorIndex = impostorIndex;
      _currentPlayer = 0;
      _revealed = false;
      _loading = false;
    });
  }

  void _nextPlayer() {
    if (_currentPlayer < widget.playerCount - 1) {
      setState(() {
        _currentPlayer++;
        _revealed = false;
      });
    } else {
      // Todos han visto su rol
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Listo!'),
          content:
              const Text('Todos los jugadores han visto su rol. ¡A jugar!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop(),
              child: const Text('Volver'),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Partida')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jugador ${_currentPlayer + 1}',
              style: Theme.of(context).textTheme.headlineMedium,
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
                isImpostor ? 'ERES EL IMPOSTOR' : _secretWord!.text,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _nextPlayer,
                child: Text(
                  _currentPlayer == widget.playerCount - 1
                      ? 'Terminar'
                      : 'Siguiente jugador',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
