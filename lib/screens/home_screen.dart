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
  InterstitialAd? _interstitialAd; // Variable para el anuncio pantalla completa
  // ------------------------------

  @override
  void initState() {
    super.initState();
    _initNameControllers();
    _loadBanner();       // Cargar Banner inferior
    _loadInterstitial(); // Pre-cargar el Intersticial para tenerlo listo
  }

  // Carga el banner del Home
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

  // Carga el anuncio Intersticial (Pantalla completa)
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
              _loadInterstitial(); // Cargar el siguiente para estar listos
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
    _interstitialAd?.dispose(); // Limpiar intersticial
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // --- LÓGICA DE JUEGO Y CONTROL DE ANUNCIOS ---

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

    // 1. Navegar al juego y ESPERAR (await) a que el usuario vuelva
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerNames: playerNames),
      ),
    );

    // 2. Al volver (cuando se cierra el GameEndDialog), verificamos si toca anuncio
    _checkAndShowInterstitial();
  }

  Future<void> _checkAndShowInterstitial() async {
    // Incrementamos el contador
    final int gamesPlayed = await Preferences.incrementGamesPlayed();
    debugPrint('Partidas jugadas: $gamesPlayed');

    // Si es múltiplo de 2 mostramos anuncio
    if (gamesPlayed % 2 == 0) {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
      } else {
        debugPrint('Tocaría anuncio, pero aún no ha cargado.');
        // Intentamos cargar uno por si acaso para la próxima
        _loadInterstitial();
      }
    }
  }

  // ---------------------------------------------

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

  @override
  Widget build(BuildContext context) {
    // DETECCIÓN DE TECLADO
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.groups, color: Colors.red.shade700, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Número de jugadores',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
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
                                      ? Colors.red.shade700.withValues(alpha: 0.2)
                                      : Colors.grey.shade800.withValues(alpha: 0.2),
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
                                    color: Colors.red.shade700.withValues(alpha: 0.2),
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
                                      ? Colors.red.shade700.withValues(alpha: 0.2)
                                      : Colors.grey.shade800.withValues(alpha: 0.2),
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
                    Expanded(
                      key: const ValueKey('lista_jugadores'), 
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(), 
                        padding: const EdgeInsets.only(bottom: 80),
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
                      ),
                    ),

                    // Si el teclado esta cerrado mostramos botones de acción
                    if (!isKeyboardOpen) ...[
                      const SizedBox(height: 16),
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
                  ],
                ),
              ),
            ),
            
            // --- BANNER DEL HOME (Solo visible si el teclado está cerrado) ---
            if (_bannerAd != null && _isBannerLoaded && !isKeyboardOpen)
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