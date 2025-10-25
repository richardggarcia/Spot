/// Constantes de la aplicación
class AppConstants {
  AppConstants._();

  /// Lista de criptomonedas por defecto (símbolos sin USDT)
  static const List<String> defaultMonitoredSymbols = [
    'BTC',
    'ETH',
    'BNB',
    'SOL',
    'XRP',
    'LINK',
    'BCH',
    'LTC',
  ];

  /// Lista completa de criptomonedas disponibles (incluyendo las con datos limitados)
  static const List<String> allAvailableSymbols = [
    // Cryptos principales con historial completo
    'BTC',
    'ETH',
    'BNB',
    'SOL',
    'XRP',
    'LINK',
    'BCH',
    'LTC',
    'TON',
    'SUI',
    'DOGE',
    'ADA',
    'AVAX',
    'DOT',
    'MATIC',
    'UNI',
    'ATOM',
    'FIL',
    'TRX',
    'ETC',
    // Cryptos con datos limitados
    'MNT',
    'KCS',
    'RON',
    'BGB',
  ];

  /// Cryptos con datos históricos limitados
  static const List<String> limitedHistorySymbols = [
    'MNT',
    'KCS',
    'RON',
    'BGB',
  ];

  /// Lista de criptomonedas a monitorear (ahora dinámico, fallback a default)
  static List<String> get monitoredSymbols => defaultMonitoredSymbols;

  /// URL base para la API Aspiradora (legacy)
  static const String aspiradoraBaseUrl = 'http://192.168.1.34:8080';

  /// URL base del servidor Spot Alerts (Node.js). Usado para registrar tokens web.
  static const String spotAlertsServerBaseUrl = 'http://192.168.1.33:3000';

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
