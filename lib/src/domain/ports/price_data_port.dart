import '../entities/crypto.dart';
import '../entities/daily_candle.dart';

/// Port (Interface) para servicios de datos de precios
/// Permite intercambiar implementaciones (Binance, CoinGecko, etc.)
/// sin afectar la lógica de dominio
abstract class PriceDataPort {
  /// Obtiene datos de precios para múltiples criptomonedas
  /// [symbols] Lista de símbolos sin sufijo (ej: ['BTC', 'ETH'])
  /// Retorna lista de entidades Crypto con datos actualizados
  /// Lanza excepción si hay error de conexión o API
  Future<List<Crypto>> getPricesForSymbols(List<String> symbols);

  /// Obtiene datos de precio para una criptomoneda específica
  /// [symbol] Símbolo sin sufijo (ej: 'BTC')
  /// Retorna entidad Crypto o null si no se encuentra
  /// Lanza excepción si hay error de conexión o API
  Future<Crypto?> getPriceForSymbol(String symbol);

  /// Obtiene el precio de cierre del día anterior para un símbolo
  /// Necesario para calcular caída profunda correctamente
  /// [symbol] Símbolo sin sufijo (ej: 'BTC')
  /// Retorna el precio de cierre del día anterior
  /// Lanza excepción si hay error de conexión o API
  Future<double> getPreviousClose(String symbol);

  /// Obtiene datos históricos de velas diarias para análisis
  /// [symbol] Símbolo sin sufijo (ej: 'BTC')
  /// [days] Número de días de historial a obtener (default: 30)
  /// Retorna lista de velas diarias (DailyCandle) ordenadas por fecha
  /// Lanza excepción si hay error de conexión o API
  Future<List<DailyCandle>> getHistoricalData(String symbol, {int days = 30});
}
