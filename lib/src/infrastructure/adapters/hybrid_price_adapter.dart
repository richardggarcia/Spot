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
    PriceDataPort? mockAdapter,
  }) : _primaryAdapter = primaryAdapter,
       _secondaryAdapter = secondaryAdapter,
       _backupAdapter = backupAdapter,
       _mockAdapter = mockAdapter;
  final PriceDataPort _primaryAdapter; // Binance
  final PriceDataPort _secondaryAdapter; // CryptoCompare
  final PriceDataPort _backupAdapter; // CoinGecko
  final PriceDataPort? _mockAdapter; // Mock fallback

  /// Cryptos que NO están en Binance (usar CryptoCompare primero)
  final Set<String> _nonBinanceSymbols = {
    'MNT', // Mantle - en Bybit
    'KCS', // KuCoin Token - no tiene par USDT en Binance
    'BGB', // Bitget Token - no está en Binance
    'BBSOL', // Wrapped SOL en Bybit
  };

  @override
  Future<List<Crypto>> getPricesForSymbols(List<String> symbols) async {
    final results = <Crypto>[];

    // Separar símbolos por fuente
    final binanceSymbols = symbols
        .where((s) => !_nonBinanceSymbols.contains(s))
        .toList();
    final nonBinanceSymbols = symbols
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
          'Binance failed, using CryptoCompare fallback for: $binanceSymbols',
        );
        // Fallback a CryptoCompare
        try {
          final fallbackResults = await _secondaryAdapter.getPricesForSymbols(
            binanceSymbols,
          );
          results.addAll(fallbackResults);
        } catch (secondaryError) {
          AppLogger.warning('CryptoCompare failed, trying CoinGecko for: $binanceSymbols');
          // Último recurso: CoinGecko
          try {
            final backupResults = await _backupAdapter.getPricesForSymbols(
              binanceSymbols,
            );
            results.addAll(backupResults);
          } catch (backupError) {
            AppLogger.error('All APIs failed for: $binanceSymbols', backupError);
            // Mock adapter como último recurso
            if (_mockAdapter != null) {
              AppLogger.warning('Using mock adapter as last resort for: $binanceSymbols');
              try {
                final mockResults = await _mockAdapter.getPricesForSymbols(binanceSymbols);
                results.addAll(mockResults);
              } catch (mockError) {
                AppLogger.error('Even mock adapter failed for: $binanceSymbols', mockError);
                rethrow;
              }
            } else {
              rethrow;
            }
          }
        }
      }
    }

    // Obtener de CryptoCompare primero para cryptos no-Binance
    if (nonBinanceSymbols.isNotEmpty) {
      try {
        AppLogger.info('Fetching from CryptoCompare: $nonBinanceSymbols');
        final cryptoCompareResults = await _secondaryAdapter.getPricesForSymbols(
          nonBinanceSymbols,
        );
        results.addAll(cryptoCompareResults);
      } catch (e) {
        AppLogger.warning('CryptoCompare failed, trying CoinGecko for: $nonBinanceSymbols');
        // Fallback a CoinGecko
        try {
          final coinGeckoResults = await _backupAdapter.getPricesForSymbols(
            nonBinanceSymbols,
          );
          results.addAll(coinGeckoResults);
        } catch (backupError) {
          AppLogger.error('Both APIs failed for: $nonBinanceSymbols', backupError);
          // Mock adapter como último recurso
          if (_mockAdapter != null) {
            AppLogger.warning('Using mock adapter as last resort for: $nonBinanceSymbols');
            try {
              final mockResults = await _mockAdapter.getPricesForSymbols(nonBinanceSymbols);
              results.addAll(mockResults);
            } catch (mockError) {
              AppLogger.error('Even mock adapter failed for: $nonBinanceSymbols', mockError);
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      }
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
