import 'package:shared_preferences/shared_preferences.dart';

/// Clase para manejar las preferencias de la aplicación
class Preferences {
  static const String _adultModeKey = 'adult_mode_enabled';
  static const String _gamesPlayedKey = 'games_played_count';

  /// Obtener si el modo +18 está activado
  static Future<bool> getAdultMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adultModeKey) ?? false;
  }

  /// Activar/desactivar el modo +18
  static Future<void> setAdultMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adultModeKey, enabled);
  }

  /// Incrementar el contador de partidas jugadas y devolver el nuevo valor
  static Future<int> incrementGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_gamesPlayedKey) ?? 0;
    int newValue = current + 1;
    await prefs.setInt(_gamesPlayedKey, newValue);
    return newValue;
  }
}