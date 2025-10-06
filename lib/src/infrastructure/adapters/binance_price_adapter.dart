import 'package:dio/dio.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_candle.dart';
import '../../domain/ports/price_data_port.dart';

/// Adapter para Binance API
/// Implementa PriceDataPort usando Binance API pública (gratis, sin límites)
/// Usa Klines para obtener previous close de manera precisa
class BinancePriceAdapter implements PriceDataPort {
  final Dio _dio;
  final String _baseUrl;

  BinancePriceAdapter({String baseUrl = 'https://api.binance.com', Dio? dio})
    : _baseUrl = baseUrl,
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
      AppLogger.info('Fetching prices from Binance for: $symbols');

      // Convertir símbolos a formato Binance (agregar USDT)
      final binanceSymbols = symbols.map((s) => '${s}USDT').toList();

      // Construir query para múltiples símbolos
      final symbolsParam = binanceSymbols.map((s) => '"$s"').join(',');

      final response = await _dio.get(
        '$_baseUrl/api/v3/ticker/24hr',
        queryParameters: {'symbols': '[$symbolsParam]'},
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'Binance API error',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = response.data as List<dynamic>;

      if (data.isEmpty) {
        throw ApiException('No data returned from Binance');
      }

      return data
          .map((json) => _mapToCrypto(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('Network error fetching from Binance', e);
      throw NetworkException(
        'Error de Conexión: Datos de Precio no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching from Binance', e);
      rethrow;
    }
  }

  @override
  Future<Crypto?> getPriceForSymbol(String symbol) async {
    try {
      AppLogger.info('Fetching price from Binance for: $symbol');

      final binanceSymbol = '${symbol}USDT';

      final response = await _dio.get(
        '$_baseUrl/api/v3/ticker/24hr',
        queryParameters: {'symbol': binanceSymbol},
      );

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw ApiException(
          'Binance API error',
          statusCode: response.statusCode,
        );
      }

      return _mapToCrypto(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      AppLogger.error('Network error fetching price from Binance', e);
      throw NetworkException(
        'Error de Conexión: Datos de Precio no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Unexpected error fetching price from Binance', e);
      rethrow;
    }
  }

  @override
  Future<double> getPreviousClose(String symbol) async {
    try {
      AppLogger.info('Fetching previous close from Binance for: $symbol');

      final binanceSymbol = '${symbol}USDT';

      // Obtener 2 klines (velas) de 1 día: ayer y hoy
      // Limit=2 nos da las últimas 2 velas diarias
      final response = await _dio.get(
        '$_baseUrl/api/v3/klines',
        queryParameters: {
          'symbol': binanceSymbol,
          'interval': '1d',
          'limit': 2,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'Binance API error',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> klines = response.data as List<dynamic>;

      if (klines.length < 2) {
        throw ApiException('Insufficient kline data from Binance');
      }

      // Kline format: [openTime, open, high, low, close, volume, closeTime, ...]
      // klines[0] = ayer
      // klines[1] = hoy
      final yesterdayKline = klines[0] as List<dynamic>;
      final yesterdayClose = double.parse(yesterdayKline[4].toString());

      AppLogger.info('Previous close for $symbol: $yesterdayClose');
      return yesterdayClose;
    } on DioException catch (e) {
      AppLogger.error('Network error fetching previous close from Binance', e);
      throw NetworkException(
        'Error de Conexión: Datos de Precio no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching previous close from Binance',
        e,
      );
      rethrow;
    }
  }

  /// Mapea respuesta de Binance 24hr ticker a entidad Crypto
  Crypto _mapToCrypto(Map<String, dynamic> json) {
    final symbol = (json['symbol'] as String).replaceAll('USDT', '');

    // Mapa local para logos de monedas principales
    final logoMap = {
      'BTC': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png',
      'ETH': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
      'BNB': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1839.png',
      'BCH': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1831.png',
      'LTC': 'https://s2.coinmarketcap.com/static/img/coins/64x64/2.png',
      'SOL': 'https://s2.coinmarketcap.com/static/img/coins/64x64/5426.png',
      'SUI': 'https://s2.coinmarketcap.com/static/img/coins/64x64/20947.png',
      'XRP': 'https://s2.coinmarketcap.com/static/img/coins/64x64/52.png',
      'LINK': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1975.png',
      'TON': 'https://s2.coinmarketcap.com/static/img/coins/64x64/11419.png',
    };

    return Crypto(
      symbol: symbol,
      name: _getDefaultName(symbol),
      imageUrl: logoMap[symbol], // Asignar logo desde el mapa
      currentPrice: double.parse(json['lastPrice'] as String),
      priceChange24h: double.parse(json['priceChange'] as String),
      priceChangePercent24h:
          double.parse(json['priceChangePercent'] as String),
      high24h: double.parse(json['highPrice'] as String),
      low24h: double.parse(json['lowPrice'] as String),
      open24h: double.parse(json['openPrice'] as String),
      volume24h: double.parse(json['volume'] as String),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        json['closeTime'] as int,
      ),
    );
  }

  /// Obtiene nombre por defecto del símbolo
  String _getDefaultName(String symbol) {
    final nameMap = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'BNB': 'Binance Coin',
      'MNT': 'Mantle',
      'BCH': 'Bitcoin Cash',
      'LTC': 'Litecoin',
      'SOL': 'Solana',
      'KCS': 'KuCoin Token',
      'TON': 'Toncoin',
      'RON': 'Ronin',
      'SUI': 'Sui',
      'BGB': 'Bitget Token',
      'XRP': 'Ripple',
      'LINK': 'Chainlink',
    };
    return nameMap[symbol] ?? symbol;
  }

  @override
  Future<List<DailyCandle>> getHistoricalData(
    String symbol, {
    int days = 30,
  }) async {
    try {
      AppLogger.info(
        'Fetching $days days of historical data for $symbol from Binance',
      );

      final binanceSymbol = '${symbol}USDT';

      // Obtener klines (velas) de 1 día
      // limit debe ser days + 1 para incluir el día de hoy
      final response = await _dio.get(
        '$_baseUrl/api/v3/klines',
        queryParameters: {
          'symbol': binanceSymbol,
          'interval': '1d',
          'limit': days + 1,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'Binance API error',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> klines = response.data as List<dynamic>;

      if (klines.isEmpty) {
        throw ApiException('No historical data returned from Binance');
      }

      // Mapear klines a DailyCandle
      // Kline format: [openTime, open, high, low, close, volume, closeTime, ...]
      final candles = klines.map((kline) {
        final k = kline as List<dynamic>;
        return DailyCandle(
          date: DateTime.fromMillisecondsSinceEpoch(k[0] as int),
          open: double.parse(k[1].toString()),
          high: double.parse(k[2].toString()),
          low: double.parse(k[3].toString()),
          close: double.parse(k[4].toString()),
          volume: double.parse(k[5].toString()),
        );
      }).toList();

      AppLogger.info('Fetched ${candles.length} candles for $symbol');
      return candles;
    } on DioException catch (e) {
      AppLogger.error('Network error fetching historical data from Binance', e);
      throw NetworkException(
        'Error de Conexión: Datos históricos no disponibles',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error fetching historical data from Binance',
        e,
      );
      rethrow;
    }
  }
}
