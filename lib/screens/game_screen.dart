import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../repositories/game_repository.dart';
import '../models/word_item.dart';
import '../utils/ad_helper.dart';
import 'game_end_dialog.dart';

class GameScreen extends StatefulWidget {
  final List<String> playerNames;

  const GameScreen({super.key, required this.playerNames});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final GameRepository _repo = GameRepository();

  WordItem? _secretWord;
  String? _categoryName;
  int? _impostorIndex;
  int _currentPlayer = 0;
  bool _revealed = false;
  bool _loading = true;
  String? _error;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Variables para el anuncio
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  int get _playerCount => widget.playerNames.length;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _startGame();
    _loadAd(); // Cargar anuncio
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.gameBannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final wordData = await _repo.getRandomWordWithCategoryFromEnabledCategories();

    if (wordData == null) {
      setState(() {
        _loading = false;
        _error = 'No hay palabras disponibles. Activa categorías o añade palabras personalizadas.';
      });
      return;
    }

    final impostorIndex = _repo.getRandomImpostorIndex(_playerCount);

    setState(() {
      _secretWord = wordData['word'] as WordItem;
      _categoryName = wordData['categoryName'] as String;
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
    final totalWeight = impostorWeight + (_playerCount - 1) * normalWeight;

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
      final starterName = widget.playerNames[startingIndex];
      final impostorName = widget.playerNames[_impostorIndex!];

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.95),
        builder: (_) => GameEndDialog(
          starterName: starterName,
          secretWord: _secretWord!.text,
          categoryName: _categoryName!,
          impostorName: impostorName,
        ),
      );
    }
  }

  void _revealRole() {
    setState(() => _revealed = true);
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              const SizedBox(height: 24),
              Text(
                'Preparando la partida...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red.shade700),
                const SizedBox(height: 24),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isImpostor = _currentPlayer == _impostorIndex;
    final currentName = widget.playerNames[_currentPlayer];
    final progress = (_currentPlayer + 1) / _playerCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Jugador ${_currentPlayer + 1} de $_playerCount'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar y nombre del jugador
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      
                      // Área de revelación
                      if (!_revealed) ...[
                        Card(
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.visibility_off,
                                  size: 60,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tu palabra está oculta',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pulsa el botón cuando estés listo',
                                  style: TextStyle(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: FilledButton.icon(
                            onPressed: _revealRole,
                            icon: const Icon(Icons.visibility, size: 28),
                            label: const Text(
                              'VER MI ROL',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ] else ...[
                        // Palabra revelada
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isImpostor
                                      ? [Colors.red.shade900, Colors.red.shade700]
                                      : [Colors.blue.shade900, Colors.blue.shade700],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isImpostor ? Colors.red : Colors.blue).withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    isImpostor ? Icons.warning : Icons.check_circle,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  if (!isImpostor && _categoryName != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _categoryName!.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  Text(
                                    isImpostor ? 'ERES EL IMPOSTOR' : _secretWord!.text.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (isImpostor) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      '¡No dejes que te descubran!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: FilledButton.icon(
                            onPressed: _nextPlayer,
                            icon: Icon(
                              _currentPlayer == _playerCount - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                              size: 28,
                            ),
                            label: Text(
                              _currentPlayer == _playerCount - 1
                                  ? 'FINALIZAR'
                                  : 'SIGUIENTE JUGADOR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // --- ANUNCIO BANNER AL FINAL DE LA PANTALLA ---
            if (_bannerAd != null && _isAdLoaded)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}