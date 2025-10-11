/// Constantes de la aplicación
class AppConstants {
  AppConstants._();

  /// Lista de criptomonedas a monitorear (símbolos sin USDT)
  static const List<String> monitoredSymbols = [
    'BTC',
    'ETH',
    'BNB',
    'MNT',
    'BCH',
    'LTC',
    'SOL',
    'KCS',
    'TON',
    'RON',
    'SUI',
    'BGB',
    'XRP',
    'LINK',
  ];

  /// URL base para la API Aspiradora
  static const String aspiradoraBaseUrl = 'https://spot.bitsdeve.com';

  /// Tiempo de timeout para peticiones HTTP (segundos)
  static const int apiTimeoutSeconds = 30;

  /// Número máximo de reintentos para peticiones fallidas
  static const int maxRetries = 3;

  /// Intervalo de auto-refresco (segundos)
  static const int autoRefreshIntervalSeconds = 60;

  /// Criterios para alertas
  static const double alertDeepDropThreshold = -0.05; // -5%
  static const double alertReboundThreshold = 0.03; // +3%

  /// Caché
  static const int cacheExpirationMinutes = 5;
  static const String cacheKeyPrefix = 'crypto_cache_';

  /// UI
  static const int maxItemsInList = 100;
  static const int defaultPaginationSize = 20;

  /// Logs
  static const String logTag = 'SpotTrading';
}
