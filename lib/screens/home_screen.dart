import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../repositories/game_repository.dart';
import '../utils/ad_helper.dart';
import '../utils/preferences.dart';
import 'game_screen.dart';
import 'categories_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameRepository _repo = GameRepository();
  int _playerCount = 4;
  final List<TextEditingController> _nameControllers = [];

  // --- VARIABLES PARA ANUNCIOS ---
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _initNameControllers();
    _loadBanner();
    _loadInterstitial();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.homeBannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Error banner home: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('Error cargando intersticial: $err');
        },
      ),
    );
  }

  void _initNameControllers() {
    _nameControllers.clear();
    for (int i = 0; i < _playerCount; i++) {
      _nameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
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

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerNames: playerNames),
      ),
    );

    _checkAndShowInterstitial();
  }

  Future<void> _checkAndShowInterstitial() async {
    final int gamesPlayed = await Preferences.incrementGamesPlayed();
    if (gamesPlayed % 2 == 0) {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
      } else {
        _loadInterstitial();
      }
    }
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

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildPlayerCounterCard({bool compact = false}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups, color: Colors.red.shade700, size: 28),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Número de jugadores',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 18 : null,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 12 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleButton(
                  icon: Icons.remove,
                  onPressed: _playerCount > 3 ? _decreasePlayers : null,
                  compact: compact,
                ),
                SizedBox(width: compact ? 20 : 32),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 24 : 32, 
                    vertical: compact ? 12 : 16
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade700, width: 2),
                  ),
                  child: Text(
                    '$_playerCount',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                          fontSize: compact ? 32 : null,
                        ),
                  ),
                ),
                SizedBox(width: compact ? 20 : 32),
                _buildCircleButton(
                  icon: Icons.add,
                  onPressed: _playerCount < 12 ? _increasePlayers : null,
                  compact: compact,
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 12),
              Text(
                '(3-12 jugadores)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon, 
    VoidCallback? onPressed, 
    bool compact = false
  }) {
    return Container(
      width: compact ? 40 : 50,
      height: compact ? 40 : 50,
      decoration: BoxDecoration(
        color: onPressed != null
            ? Colors.red.shade700.withValues(alpha: 0.2)
            : Colors.grey.shade800.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: compact ? 20 : 28,
        color: onPressed != null ? Colors.red.shade700 : Colors.grey,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Comenzar Partida',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            icon: const Icon(Icons.category),
            label: const Text('Categorías', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // Widget unificado para la lista de jugadores
  Widget _buildPlayerList({bool compact = false}) {
    // Si es compact (horizontal), usamos shrinkWrap para que la lista
    // ocupe solo el espacio necesario y se pueda centrar.
    // Si no es compact (vertical), usamos Expanded fuera de este método.
    return ListView.builder(
      shrinkWrap: compact, 
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20), 
      itemCount: _playerCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TextField(
            controller: _nameControllers[index],
            decoration: InputDecoration(
              labelText: 'Jugador ${index + 1}',
              prefixIcon: Icon(
                Icons.account_circle,
                color: Colors.red.shade700.withValues(alpha: 0.7),
              ),
              hintText: 'Nombre opcional',
            ),
          ),
        );
      },
    );
  }

  // --- LAYOUTS ---

  Widget _buildPortraitLayout(bool isKeyboardOpen) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlayerCounterCard(),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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

                Expanded(child: _buildPlayerList(compact: false)),
                
                if (!isKeyboardOpen) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(bool isKeyboardOpen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // IZQUIERDA: Controles
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPlayerCounterCard(compact: true),
                    const SizedBox(height: 16),
                    _buildActionButtons(), 
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // DERECHA: Lista de jugadores
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.red.shade700, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Nombres',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _buildPlayerList(compact: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.privacy_tip, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Juego del Impostor'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Ajustes',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000), // Ancho máximo general
                  child: isLandscape 
                    ? _buildLandscapeLayout(isKeyboardOpen) 
                    : _buildPortraitLayout(isKeyboardOpen),
                ),
              ),
            ),
            
            // Banner Fijo abajo
            if (_bannerAd != null && _isBannerLoaded && !isKeyboardOpen)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(), 
                child: AdWidget(
                  key: ValueKey(MediaQuery.of(context).orientation), 
                  ad: _bannerAd!
                ),
              ),
          ],
        ),
      ),
    );
  }
}