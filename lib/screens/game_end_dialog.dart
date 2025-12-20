import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_helper.dart';

class GameEndDialog extends StatefulWidget {
  final String starterName;
  final String secretWord;
  final String categoryName;
  final String impostorName;

  const GameEndDialog({
    super.key,
    required this.starterName,
    required this.secretWord,
    required this.categoryName,
    required this.impostorName,
  });

  @override
  State<GameEndDialog> createState() => _GameEndDialogState();
}

class _GameEndDialogState extends State<GameEndDialog> with TickerProviderStateMixin {
  bool _wordRevealed = false;
  bool _impostorRevealed = false;
  
  late AnimationController _wordAnimController;
  late AnimationController _impostorAnimController;
  late Animation<double> _wordScaleAnim;
  late Animation<double> _impostorScaleAnim;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    
    _wordAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _impostorAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _wordScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _wordAnimController, curve: Curves.elasticOut),
    );
    
    _impostorScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _impostorAnimController, curve: Curves.elasticOut),
    );

    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.dialogBannerId,
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
    _wordAnimController.dispose();
    _impostorAnimController.dispose();
    super.dispose();
  }

  void _revealWord() {
    setState(() => _wordRevealed = true);
    _wordAnimController.forward();
  }

  void _revealImpostor() {
    setState(() => _impostorRevealed = true);
    _impostorAnimController.forward();
  }

  Widget _buildStarterInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Todos los jugadores conocen su rol.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade700.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade700, width: 2),
          ),
          child: Row(
            children: [
              Icon(Icons.play_arrow, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Empieza:', style: TextStyle(fontSize: 14)),
                    Text(
                      widget.starterName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRevealButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revelar información:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        // Palabra
        if (!_wordRevealed)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _revealWord,
              icon: Icon(Icons.visibility, color: Colors.blue.shade700),
              label: const Text('Revelar palabra'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade700),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        else
          ScaleTransition(
            scale: _wordScaleAnim,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(widget.categoryName.toUpperCase(),
                      style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(widget.secretWord.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Impostor
        if (!_impostorRevealed)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _revealImpostor,
              icon: Icon(Icons.warning, color: Colors.orange.shade700),
              label: const Text('Revelar impostor'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade700),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        else
          ScaleTransition(
            scale: _impostorScaleAnim,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('EL IMPOSTOR ERA',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(widget.impostorName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
          const SizedBox(width: 12),
          const Expanded(child: Text('¡Listo para jugar!')),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700), // Limitar ancho en tablet
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLandscape)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStarterInfo()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildRevealButtons()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildStarterInfo(),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildRevealButtons(),
                  ],
                ),
              
              const SizedBox(height: 20),
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
      ),
      actions: [
        FilledButton.icon(
          onPressed: () => Navigator.of(context)..pop()..pop(),
          icon: const Icon(Icons.check),
          label: const Text('Terminar Ronda'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}