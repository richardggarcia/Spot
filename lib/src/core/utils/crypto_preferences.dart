import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Utilidad para gestionar las preferencias de criptomonedas seleccionadas
class CryptoPreferences {
  static const String _selectedCryptosKey = 'selected_cryptos';
  
  /// Obtiene la lista de cryptos seleccionadas por el usuario
  static Future<List<String>> getSelectedCryptos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCryptos = prefs.getStringList(_selectedCryptosKey);
      
      if (savedCryptos != null && savedCryptos.isNotEmpty) {
        return savedCryptos;
      } else {
        // Si no hay selección guardada, usar las por defecto
        return AppConstants.defaultMonitoredSymbols;
      }
    } catch (e) {
      // En caso de error, usar las por defecto
      return AppConstants.defaultMonitoredSymbols;
    }
  }
  
  /// Guarda la lista de cryptos seleccionadas
  static Future<void> saveSelectedCryptos(List<String> symbols) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_selectedCryptosKey, symbols);
    } catch (e) {
      // Error al guardar, se ignora silenciosamente
    }
  }
  
  /// Verifica si una crypto específica está seleccionada
  static Future<bool> isCryptoSelected(String symbol) async {
    final selected = await getSelectedCryptos();
    return selected.contains(symbol);
  }
  
  /// Agrega una crypto a la selección
  static Future<void> addCrypto(String symbol) async {
    final current = await getSelectedCryptos();
    if (!current.contains(symbol)) {
      current.add(symbol);
      await saveSelectedCryptos(current);
    }
  }
  
  /// Remueve una crypto de la selección
  static Future<void> removeCrypto(String symbol) async {
    final current = await getSelectedCryptos();
    if (current.contains(symbol) && current.length > 1) {
      // No permitir que se quede vacía la lista
      current.remove(symbol);
      await saveSelectedCryptos(current);
    }
  }
  
  /// Resetea a la selección por defecto
  static Future<void> resetToDefault() async {
    await saveSelectedCryptos(AppConstants.defaultMonitoredSymbols);
  }
}