import '../../core/utils/crypto_preferences.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_metrics.dart';
import '../../domain/ports/price_data_port.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/services/trading_calculator.dart';
import '../adapters/logo_enrichment_adapter.dart';

/// Implementación del repositorio de criptomonedas
/// Usa Ports (interfaces) para comunicarse con servicios externos
/// Sigue arquitectura hexagonal - independiente de implementaciones específicas
class CryptoRepositoryImpl implements CryptoRepository {

  CryptoRepositoryImpl({
    required PriceDataPort priceDataPort,
    required LogoEnrichmentAdapter logoEnrichmentAdapter,
    required TradingCalculator calculator,
    required List<String> monitoredSymbols,
  })  : _priceDataPort = priceDataPort,
        _logoEnrichmentAdapter = logoEnrichmentAdapter,
        _calculator = calculator,
        _monitoredSymbols = monitoredSymbols;
  final PriceDataPort _priceDataPort;
  final LogoEnrichmentAdapter _logoEnrichmentAdapter;
  final TradingCalculator _calculator;
  final List<String> _monitoredSymbols;

  /// Obtiene los símbolos monitoreados actuales desde las preferencias
  /// Esto permite que la lista se actualice dinámicamente sin reiniciar la app
  Future<List<String>> _getMonitoredSymbols() async {
    try {
      final symbols = await CryptoPreferences.getSelectedCryptos();
      AppLogger.info('Loaded ${symbols.length} monitored symbols from preferences');
      return symbols;
    } catch (e) {
      AppLogger.warning('Failed to load preferences, using fallback: $e');
      return _monitoredSymbols; // Fallback a la lista inicial
    }
  }

  @override
  Future<List<Crypto>> getAllCryptos() async {
    final symbols = await _getMonitoredSymbols();
    AppLogger.info('Getting all cryptos for symbols: $symbols');
    final cryptos = await _priceDataPort.getPricesForSymbols(symbols);
    return _logoEnrichmentAdapter.enrichLogos(cryptos);
  }

  @override
  Future<Crypto?> getCryptoBySymbol(String symbol) async {
    AppLogger.info('Getting crypto for symbol: $symbol');
    // El enriquecimiento de logo se hace principalmente en listas
    return _priceDataPort.getPriceForSymbol(symbol);
  }

  @override
  Future<List<Crypto>> getCryptosBySymbols(List<String> symbols) async {
    AppLogger.info('Getting cryptos for symbols: $symbols');
    final cryptos = await _priceDataPort.getPricesForSymbols(symbols);
    return _logoEnrichmentAdapter.enrichLogos(cryptos);
  }

  @override
  Future<List<Crypto>> refreshAllCryptos() async {
    final symbols = await _getMonitoredSymbols();
    AppLogger.info('Refreshing all cryptos for symbols: $symbols');
    return _priceDataPort.getPricesForSymbols(symbols);
  }

  @override
  Future<Crypto?> refreshCrypto(String symbol) async {
    AppLogger.info('Refreshing crypto: $symbol');
    return _priceDataPort.getPriceForSymbol(symbol);
  }

  /// Calcula métricas diarias para una criptomoneda
  @override
  Future<DailyMetrics> calculateDailyMetrics(String cryptoSymbol) async {
    AppLogger.info('Calculating daily metrics for: $cryptoSymbol');

    final crypto = await getCryptoBySymbol(cryptoSymbol);
    if (crypto == null) {
      throw Exception('Criptomoneda no encontrada: $cryptoSymbol');
    }

    // Obtener precio de cierre anterior
    final previousClose = await _priceDataPort.getPreviousClose(cryptoSymbol);

    return _calculator.calculateDailyMetrics(
      crypto,
      previousClose: previousClose,
    );
  }

  /// Calcula métricas diarias para todas las criptomonedas
  @override
  Future<Map<String, DailyMetrics>> calculateAllDailyMetrics() async {
    try {
      AppLogger.info('Calculating all daily metrics');

      final cryptos = await getAllCryptos();
      AppLogger.info('Got ${cryptos.length} cryptos, fetching previous closes...');

      // Obtener todos los precios de cierre anterior en paralelo
      final futures = cryptos.map((crypto) async {
        try {
          final close = await _priceDataPort.getPreviousClose(crypto.symbol);
          AppLogger.info('Got previous close for ${crypto.symbol}: $close');
          // Usamos MapEntry para mantener la asociación símbolo -> precio
          return MapEntry(crypto.symbol, close);
        } catch (e) {
          AppLogger.warning(
            'Could not get previous close for ${crypto.symbol}: $e',
          );
          // Retornamos null para indicar que esta llamada falló
          return MapEntry(crypto.symbol, null);
        }
      }).toList();

      // Esperamos a que todas las llamadas terminen, incluso si algunas fallaron
      final results = await Future.wait(futures);

      // Construimos el mapa de precios de cierre, ignorando los que fallaron
      final previousCloses = <String, double>{};
      for (final result in results) {
        if (result.value != null) {
          previousCloses[result.key] = result.value!;
        }
      }

      AppLogger.info('Got previous closes for ${previousCloses.length}/${cryptos.length} cryptos');

      final metricsMap = _calculator.calculateBatchMetrics(
        cryptos,
        previousCloses: previousCloses,
      );

      AppLogger.info('Calculated metrics for ${metricsMap.length} cryptos');

      return metricsMap;
    } catch (e, stackTrace) {
      AppLogger.error('Error calculating all daily metrics', e);
      AppLogger.error('Stack trace', stackTrace);
      rethrow;
    }
  }

  /// Obtiene métricas con alertas activas
  @override
  Future<List<DailyMetrics>> getActiveAlerts() async {
    try {
      final metricsMap = await calculateAllDailyMetrics();
      return _calculator.filterAlerts(metricsMap);
    } catch (e) {
      throw Exception('Error al obtener alertas: $e');
    }
  }

  /// Obtiene las mejores oportunidades de compra
  @override
  Future<List<DailyMetrics>> getTopOpportunities({int limit = 5}) async {
    try {
      final metricsMap = await calculateAllDailyMetrics();
      return _calculator.getTopOpportunities(metricsMap, limit: limit);
    } catch (e) {
      throw Exception('Error al obtener oportunidades: $e');
    }
  }
}
