import '../../core/utils/logger.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_candle.dart';
import '../../domain/ports/price_data_port.dart';

/// Adapter híbrido con fallback automático
/// Prioridad: Binance (gratis) → CryptoCompare (gratis 100k calls/mes) → CoinGecko (backup con límites)
/// Maneja automáticamente cryptos no disponibles en cada API
class HybridPriceAdapter implements PriceDataPort {

  HybridPriceAdapter({
    required PriceDataPort primaryAdapter,
    required PriceDataPort secondaryAdapter,
    required PriceDataPort backupAdapter,
  }) : _primaryAdapter = primaryAdapter,
       _secondaryAdapter = secondaryAdapter,
       _backupAdapter = backupAdapter;
  final PriceDataPort _primaryAdapter; // Binance
  final PriceDataPort _secondaryAdapter; // CryptoCompare
  final PriceDataPort _backupAdapter; // CoinGecko

  /// Cryptos que NO están en Binance (usar CryptoCompare primero)
  final Set<String> _nonBinanceSymbols = {
    'MNT', // Mantle - en Bybit
    'KCS', // KuCoin Token - no tiene par USDT en Binance
    'BGB', // Bitget Token - no está en Binance
    'BBSOL', // Wrapped SOL en Bybit
  };

  @override
  Future<List<Crypto>> getPricesForSymbols(List<String> symbols) async {
    AppLogger.info('Fetching prices for ${symbols.length} symbols: $symbols');
    final results = <Crypto>[];

    // Procesar cada símbolo individualmente para evitar que un fallo rompa todo
    final futures = symbols.map((symbol) async {
      try {
        final crypto = await getPriceForSymbol(symbol);
        if (crypto != null) {
          return crypto;
        } else {
          AppLogger.warning('No data found for symbol: $symbol');
          return null;
        }
      } catch (e) {
        AppLogger.error('Failed to fetch price for $symbol, skipping', e);
        return null; // Continuar con los demás aunque uno falle
      }
    });

    // Esperar a que todos terminen (incluso los que fallen)
    final fetchedCryptos = await Future.wait(futures);

    // Filtrar los null (los que fallaron)
    for (final crypto in fetchedCryptos) {
      if (crypto != null) {
        results.add(crypto);
      }
    }

    AppLogger.info('Successfully fetched ${results.length}/${symbols.length} cryptos');

    // Si NO se pudo cargar ninguna, lanzar error
    if (results.isEmpty && symbols.isNotEmpty) {
      throw Exception('Failed to fetch data for all ${symbols.length} symbols');
    }

    return results;
  }



  @override
  Future<Crypto?> getPriceForSymbol(String symbol) async {
    // Determinar qué adapter usar primero
    final adapter = _nonBinanceSymbols.contains(symbol)
        ? _secondaryAdapter // CryptoCompare para non-Binance
        : _primaryAdapter; // Binance para el resto

    try {
      final adapterName = adapter == _primaryAdapter ? "Binance" : "CryptoCompare";
      AppLogger.info('Fetching $symbol from $adapterName');
      return await adapter.getPriceForSymbol(symbol);
    } catch (e) {
      // Intentar con CryptoCompare si Binance falla, o CoinGecko si CryptoCompare falla
      final fallbackAdapter = adapter == _primaryAdapter
          ? _secondaryAdapter
          : _backupAdapter;
      final fallbackName = adapter == _primaryAdapter ? "CryptoCompare" : "CoinGecko";
      AppLogger.warning('Primary adapter failed for $symbol, trying $fallbackName');

      try {
        return await fallbackAdapter.getPriceForSymbol(symbol);
      } catch (fallbackError) {
        AppLogger.error('All adapters failed for $symbol', fallbackError);
        rethrow;
      }
    }
  }

  @override
  Future<double> getPreviousClose(String symbol) async {
    // Determinar qué adapter usar
    final adapter = _nonBinanceSymbols.contains(symbol)
        ? _secondaryAdapter
        : _primaryAdapter;

    try {
      final adapterName = adapter == _primaryAdapter ? "Binance" : "CryptoCompare";
      AppLogger.info(
        'Fetching previous close for $symbol from $adapterName',
      );
      return await adapter.getPreviousClose(symbol);
    } catch (e) {
      // Intentar con el siguiente adapter
      final fallbackAdapter = adapter == _primaryAdapter
          ? _secondaryAdapter
          : _backupAdapter;
      final fallbackName = adapter == _primaryAdapter ? "CryptoCompare" : "CoinGecko";
      AppLogger.warning(
        'Primary adapter failed for $symbol previous close, trying $fallbackName',
      );

      try {
        return await fallbackAdapter.getPreviousClose(symbol);
      } catch (fallbackError) {
        AppLogger.error(
          'All adapters failed for $symbol previous close',
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
    // Para cryptos no-Binance, usar CryptoCompare primero (mejor que CoinGecko sin API key)
    final adapter = _nonBinanceSymbols.contains(symbol)
        ? _secondaryAdapter
        : _primaryAdapter;
    final adapterName = adapter == _primaryAdapter ? 'Binance' : 'CryptoCompare';

    try {
      AppLogger.info('Fetching historical data for $symbol from $adapterName');
      return await adapter.getHistoricalData(symbol, days: days);
    } catch (e) {
      // Si CryptoCompare falla, intentar con CoinGecko
      // Si Binance falla, intentar con CryptoCompare primero
      final fallbackAdapter = adapter == _primaryAdapter
          ? _secondaryAdapter
          : _backupAdapter;
      final fallbackName = adapter == _primaryAdapter
          ? 'CryptoCompare'
          : 'CoinGecko';
      AppLogger.warning(
        'Primary adapter ($adapterName) failed for $symbol historical data, trying fallback ($fallbackName)',
      );

      try {
        return await fallbackAdapter.getHistoricalData(symbol, days: days);
      } catch (fallbackError) {
        // Último intento: si era Binance→CryptoCompare, probar CoinGecko
        if (adapter == _primaryAdapter) {
          AppLogger.warning(
            'CryptoCompare also failed for $symbol historical data, trying CoinGecko as last resort',
          );
          try {
            return await _backupAdapter.getHistoricalData(symbol, days: days);
          } catch (lastError) {
            AppLogger.error(
              'All adapters failed for $symbol historical data',
              lastError,
            );
            rethrow;
          }
        }

        AppLogger.error(
          'All adapters failed for $symbol historical data',
          fallbackError,
        );
        rethrow;
      }
    }
  }
}
