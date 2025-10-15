import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_candle.dart';

import '../../domain/ports/price_data_port.dart';

/// Adapter para CoinGecko API
/// Backup para cryptos que no están en Binance
/// Requiere API key (plan Demo gratuito: 10K calls/mes)
class CoinGeckoPriceAdapter implements PriceDataPort {
  final Dio _dio;
  final String _baseUrl;
  final String? _apiKey;

  CoinGeckoPriceAdapter({
    String baseUrl = 'https://api.coingecko.com/api/v3',
    String? apiKey,
    Dio? dio,
  }) : _baseUrl = baseUrl,
       _apiKey = apiKey,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 30),
               receiveTimeout: const Duration(seconds: 30),
             ),
           );

  @override
  Future<List<Crypto>> getPricesForSymbols(List<String> symbols) async {
    try {
      AppLogger.info('Fetching prices from CoinGecko for: $symbols');

      // Convertir símbolos a IDs de CoinGecko
      final coinIds = symbols.map((s) => _symbolToCoinGeckoId(s)).join(',');

      final response = await _dio.get(
        '$_baseUrl/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'ids': coinIds,
          if (_apiKey != null) 'x_cg_demo_api_key': _apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'CoinGecko API error',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data as List<dynamic>;

      if (data.isEmpty) {
        throw ApiException('No data returned from CoinGecko');
      }

      return data
          .map((json) => _mapToCrypto(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('Network error fetching from CoinGecko', e);
      throw NetworkException(
        'Error de Conexión: Datos de Precio no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching from CoinGecko', e);
      rethrow;
    }
  }

  @override
  Future<Crypto?> getPriceForSymbol(String symbol) async {
    try {
      AppLogger.info('Fetching price from CoinGecko for: $symbol');

      final coinId = _symbolToCoinGeckoId(symbol);

      final response = await _dio.get(
        '$_baseUrl/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'ids': coinId,
          if (_apiKey != null) 'x_cg_demo_api_key': _apiKey,
        },
      );

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw ApiException(
          'CoinGecko API error',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data as List<dynamic>;

      if (data.isEmpty) {
        return null;
      }

      return _mapToCrypto(data.first as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      AppLogger.error('Network error fetching price from CoinGecko', e);
      throw NetworkException(
        'Error de Conexión: Datos de Precio no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching price from CoinGecko', e);
      rethrow;
    }
  }

  @override
  Future<double> getPreviousClose(String symbol) async {
    // NOTA: Esta función ahora calcula un cierre anterior APROXIMADO.
    // La llamada a /ohlc de CoinGecko es inestable para algunas monedas.
    // Usamos los datos de 24h que ya tenemos para evitar una llamada de red adicional y frágil.
    try {
      final crypto = await getPriceForSymbol(symbol);
      if (crypto == null) {
        throw ApiException('No se pudo obtener el precio para $symbol para calcular el cierre anterior.');
      }

      // Cierre Anterior ≈ Precio Actual - Cambio de las 24h
      final previousClose = crypto.currentPrice - crypto.priceChange24h;
      AppLogger.info('Approx. previous close for $symbol: $previousClose');
      return previousClose;

    } catch (e) {
      AppLogger.error(
        'Unexpected error calculating previous close for $symbol',
        e,
      );
      rethrow;
    }
  }

  /// Mapea respuesta de CoinGecko a entidad Crypto
  Crypto _mapToCrypto(Map<String, dynamic> json) {
    final symbol = (json['symbol'] as String).toUpperCase();

    return Crypto(
      symbol: symbol,
      name: json['name'] as String,
      imageUrl: json['image'] as String?,
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChange24h: (json['price_change_24h'] as num).toDouble(),
      priceChangePercent24h:
          (json['price_change_percentage_24h'] as num).toDouble(), // Ya viene en %, no dividir
      high24h: (json['high_24h'] as num).toDouble(),
      low24h: (json['low_24h'] as num).toDouble(),
      open24h:
          (json['current_price'] as num).toDouble() -
          (json['price_change_24h'] as num).toDouble(),
      volume24h: (json['total_volume'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  /// Convierte símbolo a ID de CoinGecko
  String _symbolToCoinGeckoId(String symbol) {
    final idMap = {
      'BTC': 'bitcoin',
      'ETH': 'ethereum',
      'BNB': 'binancecoin',
      'MNT': 'mantle',
      'BCH': 'bitcoin-cash',
      'LTC': 'litecoin',
      'SOL': 'solana',
      'KCS': 'kucoin-shares',
      'TON': 'the-open-network',
      'RON': 'ronin',
      'SUI': 'sui',
      'BGB': 'bitget-token',
      'XRP': 'ripple',
      'LINK': 'chainlink',
    };
    return idMap[symbol] ?? symbol.toLowerCase();
  }

  @override
  Future<List<DailyCandle>> getHistoricalData(
    String symbol, {
    int days = 30,
  }) async {
    try {
      AppLogger.info(
        'Fetching $days days of historical data for $symbol from CoinGecko',
      );

      final coinId = _symbolToCoinGeckoId(symbol);

      // CoinGecko OHLC endpoint: /coins/{id}/ohlc
      // Retorna datos OHLC en formato: [[timestamp, open, high, low, close], ...]
      final response = await _dio.get(
        '$_baseUrl/coins/$coinId/ohlc',
        queryParameters: {
          'vs_currency': 'usd',
          'days': days.toString(),
          if (_apiKey != null) 'x_cg_demo_api_key': _apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'CoinGecko API error',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> ohlcData = response.data as List<dynamic>;

      if (ohlcData.isEmpty) {
        throw ApiException('No historical data returned from CoinGecko');
      }

      // Mapear datos OHLC a DailyCandle
      // Formato CoinGecko: [timestamp_ms, open, high, low, close]
      // Nota: CoinGecko OHLC no incluye volumen, usamos 0 como placeholder
      final candles = ohlcData.map((ohlc) {
        final data = ohlc as List<dynamic>;
        return DailyCandle(
          date: DateTime.fromMillisecondsSinceEpoch(data[0] as int, isUtc: true),
          open: (data[1] as num).toDouble(),
          high: (data[2] as num).toDouble(),
          low: (data[3] as num).toDouble(),
          close: (data[4] as num).toDouble(),
          volume: 0.0, // CoinGecko OHLC no incluye volumen
        );
      }).toList();

      AppLogger.info('Fetched ${candles.length} candles for $symbol from CoinGecko');
      return candles;
    } on DioException catch (e) {
      AppLogger.error('Network error fetching historical data from CoinGecko', e);
      throw NetworkException(
        'Error de Conexión: Datos históricos no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching historical data from CoinGecko',
        e,
      );
      rethrow;
    }
  }
}
