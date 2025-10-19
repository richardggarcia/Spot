import '../../core/utils/logger.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_candle.dart';
import '../../domain/ports/price_data_port.dart';

/// Adapter híbrido con fallback automático
/// Prioridad: Binance (gratis) → CoinGecko (backup)
/// Maneja automáticamente cryptos no disponibles en cada API
class HybridPriceAdapter implements PriceDataPort {

  HybridPriceAdapter({
    required PriceDataPort primaryAdapter,
    required PriceDataPort backupAdapter,
  }) : _primaryAdapter = primaryAdapter,
       _backupAdapter = backupAdapter;
  final PriceDataPort _primaryAdapter; // Binance
  final PriceDataPort _backupAdapter; // CoinGecko

  /// Cryptos que NO están en Binance (usar CoinGecko directamente)
  final Set<String> _nonBinanceSymbols = {
    'MNT', // Mantle
    'RON', // Ronin
    'KCS', // KuCoin Token - no tiene par USDT en Binance
    'BGB', // Bitget Token - no está en Binance
  };

  @override
  Future<List<Crypto>> getPricesForSymbols(List<String> symbols) async {
    final results = <Crypto>[];

    // Separar símbolos por fuente
    final binanceSymbols = symbols
        .where((s) => !_nonBinanceSymbols.contains(s))
        .toList();
    final coinGeckoSymbols = symbols
        .where(_nonBinanceSymbols.contains)
        .toList();

    // Obtener de Binance (mayoría de cryptos)
    if (binanceSymbols.isNotEmpty) {
      try {
        AppLogger.info('Fetching from Binance: $binanceSymbols');
        final binanceResults = await _primaryAdapter.getPricesForSymbols(
          binanceSymbols,
        );
        results.addAll(binanceResults);
      } catch (e) {
        AppLogger.warning(
          'Binance failed, using CoinGecko fallback for: $binanceSymbols',
        );
        // Fallback a CoinGecko
        try {
          final fallbackResults = await _backupAdapter.getPricesForSymbols(
            binanceSymbols,
          );
          results.addAll(fallbackResults);
        } catch (backupError) {
          AppLogger.error('Both APIs failed for: $binanceSymbols', backupError);
          rethrow;
        }
      }
    }

    // Obtener de CoinGecko (cryptos no-Binance)
    if (coinGeckoSymbols.isNotEmpty) {
      try {
        AppLogger.info('Fetching from CoinGecko: $coinGeckoSymbols');
        final coinGeckoResults = await _backupAdapter.getPricesForSymbols(
          coinGeckoSymbols,
        );
        results.addAll(coinGeckoResults);
      } catch (e) {
        AppLogger.error('CoinGecko failed for: $coinGeckoSymbols', e);
        // No hay fallback para estas (solo CoinGecko las tiene)
        rethrow;
      }
    }

    return results;
  }

  @override
  Future<Crypto?> getPriceForSymbol(String symbol) async {
    // Determinar qué adapter usar
    final adapter = _nonBinanceSymbols.contains(symbol)
        ? _backupAdapter
        : _primaryAdapter;

    try {
      AppLogger.info(
        'Fetching $symbol from ${adapter == _primaryAdapter ? "Binance" : "CoinGecko"}',
      );
      return await adapter.getPriceForSymbol(symbol);
    } catch (e) {
      // Intentar con el otro adapter
      final fallbackAdapter = adapter == _primaryAdapter
          ? _backupAdapter
          : _primaryAdapter;
      AppLogger.warning('Primary adapter failed for $symbol, trying fallback');

      try {
        return await fallbackAdapter.getPriceForSymbol(symbol);
      } catch (fallbackError) {
        AppLogger.error('Both adapters failed for $symbol', fallbackError);
        rethrow;
      }
    }
  }

  @override
  Future<double> getPreviousClose(String symbol) async {
    // Determinar qué adapter usar
    final adapter = _nonBinanceSymbols.contains(symbol)
        ? _backupAdapter
        : _primaryAdapter;

    try {
      AppLogger.info(
        'Fetching previous close for $symbol from ${adapter == _primaryAdapter ? "Binance" : "CoinGecko"}',
      );
      return await adapter.getPreviousClose(symbol);
    } catch (e) {
      // Intentar con el otro adapter
      final fallbackAdapter = adapter == _primaryAdapter
          ? _backupAdapter
          : _primaryAdapter;
      AppLogger.warning(
        'Primary adapter failed for $symbol previous close, trying fallback',
      );

      try {
        return await fallbackAdapter.getPreviousClose(symbol);
      } catch (fallbackError) {
        AppLogger.error(
          'Both adapters failed for $symbol previous close',
          fallbackError,
        );
        rethrow;
      }
    }
  }

  @override
  Future<List<DailyCandle>> getHistoricalData(
    String symbol, {
    int days = 30,
  }) async {
    final adapter = _nonBinanceSymbols.contains(symbol)
        ? _backupAdapter
        : _primaryAdapter;
    final adapterName = adapter == _primaryAdapter ? 'Binance' : 'CoinGecko';

    try {
      AppLogger.info('Fetching historical data for $symbol from $adapterName');
      return await adapter.getHistoricalData(symbol, days: days);
    } catch (e) {
      final fallbackAdapter = adapter == _primaryAdapter
          ? _backupAdapter
          : _primaryAdapter;
      final fallbackName = fallbackAdapter == _primaryAdapter
          ? 'Binance'
          : 'CoinGecko';
      AppLogger.warning(
        'Primary adapter ($adapterName) failed for $symbol historical data, trying fallback ($fallbackName)',
      );

      try {
        return await fallbackAdapter.getHistoricalData(symbol, days: days);
      } catch (fallbackError) {
        AppLogger.error(
          'Both adapters failed for $symbol historical data',
          fallbackError,
        );
        rethrow;
      }
    }
  }
}
