import 'dart:io';

class AdHelper {
  // --- ID DE PRUEBA DE GOOGLE (Para desarrollo) ---
  static const String _androidTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestId = 'ca-app-pub-3940256099942544/2934735716';

  static const String _androidTestInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  // --- IDs REALES (Para producción) ---
  static const String _androidHomeRealId = 'ca-app-pub-7978561314341617/5696396411'; // El de tu foto
  static const String _androidGameRealId = 'ca-app-pub-7978561314341617/5614304231';
  static const String _androidDialogRealId = 'ca-app-pub-7978561314341617/1305741175';
  static const String _androidRealInterstitialId = 'ca-app-pub-7978561314341617/3479095481';

  // 1. BANNER DEL HOME
  static String get homeBannerId {
    if (Platform.isAndroid) {
      return _androidTestId; // Cambiar a _androidHomeRealId para publicar
    } else if (Platform.isIOS) {
      return _iosTestId;
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  // 2. BANNER DE LA PANTALLA DE JUEGO
  static String get gameBannerId {
    if (Platform.isAndroid) {
      return _androidTestId; // Cambiar a _androidGameRealId para publicar
    } else if (Platform.isIOS) {
      return _iosTestId;
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  // 3. BANNER DEL DIÁLOGO FINAL
  static String get dialogBannerId {
    if (Platform.isAndroid) {
      return _androidTestId; // Cambiar a _androidDialogRealId para publicar
    } else if (Platform.isIOS) {
      return _iosTestId;
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  // 4. INTERSTICIAL (PANTALLA COMPLETA)
  static String get interstitialAdId {
    if (Platform.isAndroid) {
      return _androidTestInterstitialId; // Cambiar por _androidRealInterstitialId al publicar
    } else if (Platform.isIOS) {
      return _iosTestInterstitialId;
    }
    throw UnsupportedError('Plataforma no soportada');
  }
}