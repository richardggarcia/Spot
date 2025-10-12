import '../entities/crypto.dart';
import '../entities/daily_metrics.dart';

/// Puerto de repositorio para datos de criptomonedas y métricas
/// Define el contrato que cualquier implementación debe cumplir
abstract class CryptoRepository {
  /// Obtiene todas las criptomonedas monitoreadas
  Future<List<Crypto>> getAllCryptos();

  /// Obtiene una criptomoneda específica por símbolo
  Future<Crypto?> getCryptoBySymbol(String symbol);

  /// Obtiene criptomonedas por lista de símbolos
  Future<List<Crypto>> getCryptosBySymbols(List<String> symbols);

  /// Refresca los datos de todas las criptomonedas
  Future<List<Crypto>> refreshAllCryptos();

  /// Refresca los datos de una criptomoneda específica
  Future<Crypto?> refreshCrypto(String symbol);

  /// Calcula métricas diarias para una criptomoneda
  Future<DailyMetrics> calculateDailyMetrics(String cryptoSymbol);

  /// Calcula métricas diarias para todas las criptomonedas
  Future<Map<String, DailyMetrics>> calculateAllDailyMetrics();

  /// Obtiene métricas con alertas activas
  Future<List<DailyMetrics>> getActiveAlerts();

  /// Obtiene las mejores oportunidades de compra
  Future<List<DailyMetrics>> getTopOpportunities({int limit = 5});


}
