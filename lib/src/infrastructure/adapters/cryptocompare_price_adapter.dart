import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_candle.dart';
import '../../domain/ports/price_data_port.dart';

/// Adapter para CryptoCompare API
/// 100% GRATIS - hasta 100,000 calls/mes sin API key
/// Implementa PriceDataPort usando CryptoCompare API pública
class CryptoComparePriceAdapter implements PriceDataPort {
  CryptoComparePriceAdapter({String? baseUrl, Dio? dio})
      : _baseUrl = baseUrl ?? 'https://min-api.cryptocompare.com',
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  final Dio _dio;
  final String _baseUrl;

  /// Mapa de símbolos a IDs de CryptoCompare (algunos tienen nombres diferentes)
  static const Map<String, String> _symbolMap = {
    'MNT': 'MANTLE', // Mantle Network - usar nombre completo para evitar conflicto con tokens viejos
    'KCS': 'KCS',
    'BGB': 'BGB',
    'BBSOL': 'SOL', // BBSOL es wrapped SOL
    'RON': 'RON',
  };

  String _mapSymbol(String symbol) => _symbolMap[symbol] ?? symbol;

  @override
  Future<List<Crypto>> getPricesForSymbols(List<String> symbols) async {
    try {
      AppLogger.info('Fetching prices from CryptoCompare for: $symbols');

      // CryptoCompare usa símbolos separados por coma
      final mappedSymbols = symbols.map(_mapSymbol).join(',');

      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/data/pricemultifull',
        queryParameters: {
          'fsyms': mappedSymbols,
          'tsyms': 'USD',
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'CryptoCompare API error',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data == null || data['RAW'] == null) {
        throw const ApiException('No data returned from CryptoCompare');
      }

      final raw = data['RAW'] as Map<String, dynamic>;
      final cryptos = <Crypto>[];

      for (final symbol in symbols) {
        final mapped = _mapSymbol(symbol);
        if (raw.containsKey(mapped)) {
          final coinData = raw[mapped]['USD'] as Map<String, dynamic>;
          cryptos.add(_mapToCrypto(symbol, coinData));
        }
      }

      return cryptos;
    } on DioException catch (e) {
      AppLogger.error('Network error fetching from CryptoCompare', e);
      throw NetworkException(
        'Error de Conexión: Datos de Precio no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching from CryptoCompare', e);
      rethrow;
    }
  }

  @override
  Future<Crypto?> getPriceForSymbol(String symbol) async {
    try {
      AppLogger.info('Fetching price from CryptoCompare for: $symbol');

      final mapped = _mapSymbol(symbol);

      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/data/pricemultifull',
        queryParameters: {
          'fsyms': mapped,
          'tsyms': 'USD',
        },
      );

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw ApiException(
          'CryptoCompare API error',
          statusCode: response.statusCode,
        );
      }

      final data = response.data;
      if (data == null || data['RAW'] == null) {
        return null;
      }

      final raw = data['RAW'] as Map<String, dynamic>;
      if (!raw.containsKey(mapped)) {
        return null;
      }

      final coinData = raw[mapped]['USD'] as Map<String, dynamic>;
      return _mapToCrypto(symbol, coinData);
    } on DioException catch (e) {
      AppLogger.error('Network error fetching from CryptoCompare', e);
      throw NetworkException(
        'Error de Conexión: Datos de Precio no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching from CryptoCompare', e);
      rethrow;
    }
  }

  @override
  Future<double> getPreviousClose(String symbol) async {
    try {
      AppLogger.info(
        'Fetching previous close for $symbol from CryptoCompare',
      );

      final mapped = _mapSymbol(symbol);

      // Obtener datos históricos del día anterior
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/data/v2/histoday',
        queryParameters: {
          'fsym': mapped,
          'tsym': 'USD',
          'limit': 2, // Últimos 2 días
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'CryptoCompare API error',
          statusCode: response.statusCode,
        );
      }

      final data = response.data?['Data']?['Data'] as List<dynamic>?;
      if (data == null || data.length < 2) {
        throw const ApiException('Insufficient historical data');
      }

      // Segundo elemento más reciente es el día anterior
      final yesterdayData = data[data.length - 2] as Map<String, dynamic>;
      return (yesterdayData['close'] as num).toDouble();
    } catch (e) {
      AppLogger.error('Error getting previous close from CryptoCompare', e);
      rethrow;
    }
  }

  @override
  Future<List<DailyCandle>> getHistoricalData(
    String symbol, {
    int days = 30,
  }) async {
    try {
      AppLogger.info(
        'Fetching $days days of historical data for $symbol from CryptoCompare',
      );

      final mapped = _mapSymbol(symbol);

      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/data/v2/histoday',
        queryParameters: {
          'fsym': mapped,
          'tsym': 'USD',
          'limit': days,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'CryptoCompare API error',
          statusCode: response.statusCode,
        );
      }

      final data = response.data?['Data']?['Data'] as List<dynamic>?;
      if (data == null || data.isEmpty) {
        throw const ApiException(
          'No historical data returned from CryptoCompare',
        );
      }

      final candles = data.map((item) {
        final candle = item as Map<String, dynamic>;
        return DailyCandle(
          date: DateTime.fromMillisecondsSinceEpoch(
            (candle['time'] as int) * 1000,
            isUtc: true,
          ),
          open: (candle['open'] as num).toDouble(),
          high: (candle['high'] as num).toDouble(),
          low: (candle['low'] as num).toDouble(),
          close: (candle['close'] as num).toDouble(),
          volume: (candle['volumeto'] as num).toDouble(), // Volume en USD
        );
      }).toList();

      AppLogger.info('Fetched ${candles.length} candles for $symbol');
      return candles;
    } catch (e) {
      AppLogger.error('Error getting historical data from CryptoCompare', e);
      rethrow;
    }
  }

  Crypto _mapToCrypto(String originalSymbol, Map<String, dynamic> data) {
    final currentPrice = (data['PRICE'] as num).toDouble();
    final change24h = (data['CHANGE24HOUR'] as num?)?.toDouble() ?? 0.0;
    final changePercent24h =
        (data['CHANGEPCT24HOUR'] as num?)?.toDouble() ?? 0.0;
    final high24h = (data['HIGH24HOUR'] as num?)?.toDouble() ?? currentPrice;
    final low24h = (data['LOW24HOUR'] as num?)?.toDouble() ?? currentPrice;
    final open24h = (data['OPEN24HOUR'] as num?)?.toDouble() ?? currentPrice;
    final volume24h = (data['VOLUME24HOUR'] as num?)?.toDouble() ?? 0.0;
    final lastUpdate = data['LASTUPDATE'];
    final lastUpdated = lastUpdate is num
        ? DateTime.fromMillisecondsSinceEpoch(
            (lastUpdate.toInt()) * 1000,
            isUtc: true,
          )
        : DateTime.now().toUtc();

    return Crypto(
      symbol: originalSymbol,
      name: data['FROMSYMBOL'] as String? ?? originalSymbol,
      currentPrice: currentPrice,
      priceChange24h: change24h,
      priceChangePercent24h: changePercent24h,
      high24h: high24h,
      low24h: low24h,
      open24h: open24h,
      volume24h: volume24h,
      lastUpdated: lastUpdated,
      imageUrl: data['IMAGEURL'] != null
          ? 'https://www.cryptocompare.com${data['IMAGEURL']}'
          : null,
    );
  }
}
