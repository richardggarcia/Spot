import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/infrastructure/adapters/binance_price_adapter.dart';

/// Test simple para verificar que Binance API funciona
/// Ejecutar con: flutter test test/binance_api_test.dart
void main() {
  group('Binance API Test', () {
    final adapter = BinancePriceAdapter();

    test('Obtiene precio actual de BTC', () async {
      final crypto = await adapter.getPriceForSymbol('BTC');

      expect(crypto, isNotNull);
    });

    test('Obtiene previous close de BTC', () async {
      final previousClose = await adapter.getPreviousClose('BTC');

      expect(previousClose, greaterThan(0));
    });

    test('Obtiene datos históricos de BTC (7 días)', () async {
      final candles = await adapter.getHistoricalData('BTC', days: 7);

      expect(candles, isNotEmpty);
      expect(candles.length, greaterThanOrEqualTo(7));
    });

    test('Obtiene múltiples cryptos', () async {
      final symbols = ['BTC', 'ETH', 'SOL'];
      final cryptos = await adapter.getPricesForSymbols(symbols);

      expect(cryptos.length, equals(3));
    });
  });
}