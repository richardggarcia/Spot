import 'package:shared_preferences/shared_preferences.dart';
import '../../infrastructure/services/user_preferences_remote_service.dart';
import '../constants/app_constants.dart';
import 'logger.dart';

/// Utilidad para gestionar las preferencias de criptomonedas seleccionadas
/// Guarda tanto localmente (SharedPreferences) como en el backend
class CryptoPreferences {
  static const String _selectedCryptosKey = 'selected_cryptos';
  static UserPreferencesRemoteService? _remoteService;

  /// Configura el servicio remoto para sincronización con backend
  static void configureRemoteService(UserPreferencesRemoteService service) {
    _remoteService = service;
  }

  /// Obtiene la lista de cryptos seleccionadas por el usuario
  /// Intenta cargar del backend primero, si falla usa SharedPreferences
  static Future<List<String>> getSelectedCryptos() async {
    try {
      // Intentar cargar del backend si está configurado
      if (_remoteService != null) {
        try {
          final remoteCryptos = await _remoteService!.loadSelectedCryptos();
          if (remoteCryptos != null && remoteCryptos.isNotEmpty) {
            // Guardar en SharedPreferences para cache local
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList(_selectedCryptosKey, remoteCryptos);
            AppLogger.info('Cryptos cargadas desde backend: ${remoteCryptos.length}');
            return remoteCryptos;
          }
        } catch (e) {
          AppLogger.warning('Error cargando cryptos del backend: $e');
        }
      }

      // Si no se pudo cargar del backend, usar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedCryptos = prefs.getStringList(_selectedCryptosKey);

      if (savedCryptos != null && savedCryptos.isNotEmpty) {
        AppLogger.info('Cryptos cargadas desde SharedPreferences: ${savedCryptos.length}');
        return savedCryptos;
      } else {
        // Si no hay selección guardada, usar las por defecto
        AppLogger.info('Usando cryptos por defecto');
        return AppConstants.defaultMonitoredSymbols;
      }
    } catch (e) {
      // En caso de error, usar las por defecto
      AppLogger.error('Error cargando cryptos: $e');
      return AppConstants.defaultMonitoredSymbols;
    }
  }

  /// Guarda la lista de cryptos seleccionadas
  /// Guarda tanto localmente como en el backend
  static Future<void> saveSelectedCryptos(List<String> symbols) async {
    try {
      // Guardar localmente primero (siempre funciona)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_selectedCryptosKey, symbols);
      AppLogger.info('Cryptos guardadas localmente: ${symbols.length}');

      // Intentar guardar en backend si está configurado
      if (_remoteService != null) {
        await _remoteService!.saveSelectedCryptos(symbols);
      }
    } catch (e) {
      AppLogger.error('Error guardando cryptos: $e');
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
