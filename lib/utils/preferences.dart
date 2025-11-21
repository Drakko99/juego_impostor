import 'package:shared_preferences/shared_preferences.dart';

/// Clase para manejar las preferencias de la aplicación
class Preferences {
  static const String _adultModeKey = 'adult_mode_enabled';

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
}