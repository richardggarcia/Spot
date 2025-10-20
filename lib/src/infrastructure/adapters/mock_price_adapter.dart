import '../../core/utils/logger.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_candle.dart';
import '../../domain/ports/price_data_port.dart';

/// Adapter con datos mock para fallback cuando las APIs fallan
/// Útil en desarrollo y cuando hay problemas de CORS en web
class MockPriceAdapter implements PriceDataPort {
  
  /// Datos mock realistas para desarrollo
  static final Map<String, Map<String, dynamic>> _mockData = {
    'BTC': {
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'price': 109315.18,
      'previousClose': 108500.00,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png',
    },
    'ETH': {
      'symbol': 'ETH', 
      'name': 'Ethereum',
      'price': 4028.95,
      'previousClose': 3980.50,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
    },
    'BNB': {
      'symbol': 'BNB',
      'name': 'BNB',
      'price': 712.45,
      'previousClose': 705.20,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1839.png',
    },
    'SOL': {
      'symbol': 'SOL',
      'name': 'Solana', 
      'price': 244.12,
      'previousClose': 239.80,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/5426.png',
    },
    'XRP': {
      'symbol': 'XRP',
      'name': 'XRP',
      'price': 2.45,
      'previousClose': 2.38,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/52.png',
    },
    'ADA': {
      'symbol': 'ADA',
      'name': 'Cardano',
      'price': 1.15,
      'previousClose': 1.12,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/2010.png',
    },
    'DOGE': {
      'symbol': 'DOGE',
      'name': 'Dogecoin',
      'price': 0.42,
      'previousClose': 0.40,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/74.png',
    },
    'LTC': {
      'symbol': 'LTC',
      'name': 'Litecoin',
      'price': 118.75,
      'previousClose': 115.30,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/2.png',
    },
    'BCH': {
      'symbol': 'BCH',
      'name': 'Bitcoin Cash',
      'price': 502.80,
      'previousClose': 495.60,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1831.png',
    },
    'LINK': {
      'symbol': 'LINK',
      'name': 'Chainlink',
      'price': 26.85,
      'previousClose': 25.90,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1975.png',
    },
    'TON': {
      'symbol': 'TON',
      'name': 'Toncoin',
      'price': 6.12,
      'previousClose': 5.95,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/11419.png',
    },
    'SUI': {
      'symbol': 'SUI',
      'name': 'Sui',
      'price': 4.68,
      'previousClose': 4.45,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/20947.png',
    },
    'MNT': {
      'symbol': 'MNT',
      'name': 'Mantle',
      'price': 1.42,
      'previousClose': 1.38,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/27075.png',
    },
    'RON': {
      'symbol': 'RON',
      'name': 'Ronin',
      'price': 2.95,
      'previousClose': 2.85,
      'logoUrl': 'https://s2.coinmarketcap.com/static/img/coins/64x64/14101.png',
    },
  };

  @override
  Future<List<Crypto>> getPricesForSymbols(List<String> symbols) async {
    AppLogger.info('🔧 Using mock data for symbols: $symbols');
    
    // Simular delay de red
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    final results = <Crypto>[];
    
    for (final symbol in symbols) {
      final mockInfo = _mockData[symbol];
      if (mockInfo != null) {
        final currentPrice = mockInfo['price'] as double;
        final previousClose = mockInfo['previousClose'] as double;
        final change = currentPrice - previousClose;
        final changePercent = (change / previousClose) * 100;
        
        results.add(Crypto(
          symbol: mockInfo['symbol'] as String,
          name: mockInfo['name'] as String,
          imageUrl: mockInfo['logoUrl'] as String,
          currentPrice: currentPrice,
          priceChange24h: change,
          priceChangePercent24h: changePercent,
          high24h: currentPrice * 1.05, // 5% más alto
          low24h: currentPrice * 0.95,  // 5% más bajo
          open24h: previousClose,
          volume24h: 1000000, // 1M de volumen mock
          lastUpdated: DateTime.now(),
        ));
      }
    }
    
    return results;
  }

  @override
  Future<Crypto?> getPriceForSymbol(String symbol) async {
    AppLogger.info('🔧 Using mock data for symbol: $symbol');
    
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    final mockInfo = _mockData[symbol];
    if (mockInfo == null) return null;
    
    final currentPrice = mockInfo['price'] as double;
    final previousClose = mockInfo['previousClose'] as double;
    final change = currentPrice - previousClose;
    final changePercent = (change / previousClose) * 100;
    
    return Crypto(
      symbol: mockInfo['symbol'] as String,
      name: mockInfo['name'] as String,
      imageUrl: mockInfo['logoUrl'] as String,
      currentPrice: currentPrice,
      priceChange24h: change,
      priceChangePercent24h: changePercent,
      high24h: currentPrice * 1.05,
      low24h: currentPrice * 0.95,
      open24h: previousClose,
      volume24h: 1000000,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<double> getPreviousClose(String symbol) async {
    AppLogger.info('🔧 Using mock previous close for symbol: $symbol');
    
    await Future<void>.delayed(const Duration(milliseconds: 200));
    
    final mockInfo = _mockData[symbol];
    return mockInfo?['previousClose'] as double? ?? 0.0;
  }

  @override
  Future<List<DailyCandle>> getHistoricalData(String symbol, {int days = 30}) async {
    AppLogger.info('🔧 Using mock historical data for symbol: $symbol');
    
    await Future<void>.delayed(const Duration(milliseconds: 400));
    
    final mockInfo = _mockData[symbol];
    if (mockInfo == null) return [];
    
    final currentPrice = mockInfo['price'] as double;
    final candles = <DailyCandle>[];
    
    // Generar datos históricos simulados
    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final variation = (i * 0.02) - 0.01; // Variación del -1% a +1%
      final open = currentPrice * (1 + variation);
      final close = currentPrice * (1 + variation * 0.8);
      final high = currentPrice * (1 + variation * 1.2);
      final low = currentPrice * (1 + variation * 0.6);
      
      candles.add(DailyCandle(
        date: date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: 1000000 + (i * 50000), // Volumen simulado
      ));
    }
    
    return candles;
  }
}