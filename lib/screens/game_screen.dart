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
    _loadAd();
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

  // --- WIDGETS ---

  Widget _buildPlayerInfo(String currentName, {bool compact = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(compact ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.red.shade700.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: compact ? 40 : 60,
            color: Colors.red.shade700,
          ),
        ),
        SizedBox(height: compact ? 12 : 24),
        Text(
          currentName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 24 : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHiddenState({bool compact = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.all(compact ? 16 : 24),
            child: Column(
              children: [
                Icon(Icons.visibility_off, size: compact ? 40 : 60, color: Colors.grey.shade700),
                const SizedBox(height: 12),
                Text(
                  'Tu palabra está oculta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: compact ? 18 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Pulsa el botón cuando estés listo',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: compact ? 16 : 32),
        SizedBox(
          width: double.infinity,
          height: compact ? 48 : 60,
          child: FilledButton.icon(
            onPressed: _revealRole,
            icon: Icon(Icons.visibility, size: compact ? 20 : 28),
            label: Text(
              'VER MI ROL',
              style: TextStyle(fontSize: compact ? 16 : 18, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevealedState(bool isImpostor, {bool compact = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(compact ? 12 : 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border.all(
                  color: isImpostor ? Colors.red.shade800 : Colors.blue.shade800,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isImpostor ? Icons.warning : Icons.check_circle,
                    size: compact ? 40 : 60,
                    color: isImpostor ? Colors.red.shade700 : Colors.blue.shade700,
                  ),
                  SizedBox(height: compact ? 8 : 16),
                  if (!isImpostor && _categoryName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _categoryName!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 20),
                  ],
                  Text(
                    isImpostor ? 'ERES EL IMPOSTOR' : _secretWord!.text.toUpperCase(),
                    style: TextStyle(
                      fontSize: compact ? 22 : 32,
                      fontWeight: FontWeight.bold,
                      color: isImpostor ? Colors.red.shade400 : Colors.blue.shade400,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isImpostor && !compact) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '¡No dejes que te descubran!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 16 : 32),
        SizedBox(
          width: double.infinity,
          height: compact ? 48 : 60,
          child: FilledButton.icon(
            onPressed: _nextPlayer,
            icon: Icon(
              _currentPlayer == _playerCount - 1 ? Icons.check : Icons.arrow_forward,
              size: compact ? 20 : 28,
            ),
            label: Text(
              _currentPlayer == _playerCount - 1 ? 'FINALIZAR' : 'SIGUIENTE JUGADOR',
              style: TextStyle(fontSize: compact ? 16 : 18, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // --- LAYOUTS PRINCIPALES ---

  // Vertical
  Widget _buildPortraitLayout(bool isImpostor, String currentName) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlayerInfo(currentName),
                const SizedBox(height: 48),
                if (!_revealed) 
                  _buildHiddenState() 
                else 
                  _buildRevealedState(isImpostor),
              ],
            ),
          ),
        ),
        if (_bannerAd != null && _isAdLoaded)
          Container(
            alignment: Alignment.center,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
      ],
    );
  }

  // Horizontal (Landscape)
  Widget _buildLandscapeLayout(bool isImpostor, String currentName) {
    return Column(
      children: [
        // Contenido principal arriba
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // IZQUIERDA: Info Jugador
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: _buildPlayerInfo(currentName, compact: true)
                  ),
                ),
                
                const SizedBox(width: 32),
                
                // DERECHA: Acciones (Dentro de un SingleChildScrollView por seguridad)
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: !_revealed 
                      ? _buildHiddenState(compact: true) 
                      : _buildRevealedState(isImpostor, compact: true),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Banner abajo, fuera del scroll para que no tape
        if (_bannerAd != null && _isAdLoaded)
          Container(
            alignment: Alignment.center,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }

    final isImpostor = _currentPlayer == _impostorIndex;
    final currentName = widget.playerNames[_currentPlayer];
    final progress = (_currentPlayer + 1) / _playerCount;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

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
        // ConstrainedBox para evitar que se desparrame en pantallas gigantes
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: isLandscape
                ? _buildLandscapeLayout(isImpostor, currentName)
                : _buildPortraitLayout(isImpostor, currentName),
          ),
        ),
      ),
    );
  }
}