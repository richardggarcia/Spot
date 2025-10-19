import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/domain/services/historical_analysis_service.dart';
import 'package:spot/src/infrastructure/adapters/binance_price_adapter.dart';

/// Test para verificar generación de reportes históricos
void main() {
  group('Historical Analysis Test', () {
    final adapter = BinancePriceAdapter();
    final analysisService = HistoricalAnalysisService();

    test('Genera reporte mensual de BTC', () async {
      // Obtener 30 días de datos
      final candles = await adapter.getHistoricalData('BTC');

      expect(candles, isNotEmpty);

      // Generar reporte mensual
      final report = analysisService.generateMonthlyReport(
        symbol: 'BTC',
        cryptoName: 'Bitcoin',
        candles: candles,
      );

      expect(report.weeks, isNotEmpty);
      expect(report.allDays, isNotEmpty);
    });
  });
}