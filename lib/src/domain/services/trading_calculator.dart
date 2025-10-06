import '../entities/crypto.dart';
import '../entities/daily_metrics.dart';

/// Servicio de dominio para cálculos de trading
/// Contiene toda la lógica matemática y de análisis
class TradingCalculator {
  /// Calcula la caída profunda (deep drop)
  /// Fórmula: (precio_mínimo / precio_cierre_ayer) - 1
  double calculateDeepDrop({
    required double currentPrice,
    required double lowPrice,
    required double previousClose,
  }) {
    if (previousClose <= 0) {
      throw ArgumentError('Previous close price must be greater than 0');
    }
    return (lowPrice / previousClose) - 1;
  }

  /// Calcula la fuerza del rebote
  /// Fórmula: (precio_actual / precio_mínimo) - 1
  double calculateRebound({
    required double currentPrice,
    required double lowPrice,
  }) {
    if (lowPrice <= 0) {
      throw ArgumentError('Low price must be greater than 0');
    }
    return (currentPrice / lowPrice) - 1;
  }

  /// Determina si hay una alerta de compra
  /// Criterio principal: caída <= -3% (rebote no es requisito)
  bool hasAlert({required double deepDrop, required double rebound}) {
    // Alerta cuando hay caída significativa (≥3%)
    // El rebote es secundario, solo verificamos que no sea negativo
    return deepDrop <= -0.03;
  }

  /// Calcula métricas diarias completas para una criptomoneda
  /// [crypto] Entidad con datos de precio actuales
  /// [previousClose] Precio de cierre del día anterior (requerido para cálculo exacto)
  /// [verdict] Análisis opcional del LLM
  DailyMetrics calculateDailyMetrics(
    Crypto crypto, {
    required double previousClose,
    String? verdict,
  }) {
    // Fórmula exacta: (Mínimo Hoy / Cierre Ayer) - 1
    final deepDrop = calculateDeepDrop(
      currentPrice: crypto.currentPrice,
      lowPrice: crypto.low24h,
      previousClose: previousClose,
    );

    // Fórmula exacta: (Cierre Hoy / Mínimo Hoy) - 1
    final rebound = calculateRebound(
      currentPrice: crypto.currentPrice,
      lowPrice: crypto.low24h,
    );

    final hasAlert = this.hasAlert(deepDrop: deepDrop, rebound: rebound);

    return DailyMetrics(
      crypto: crypto,
      deepDrop: deepDrop,
      rebound: rebound,
      hasAlert: hasAlert,
      verdict: verdict,
      calculatedAt: DateTime.now(),
    );
  }

  /// Genera veredicto mock (simulación de análisis LLM)
  String generateMockVerdict(Crypto crypto) {
    final veredicts = [
      'Caída por profit taking',
      'Soporte defendido por recompra',
      'Corrección del mercado general',
      'Noticias regulatorias negativas',
      'Acumulación por inversores',
      'Toma de ganancias técnica',
      'Fuerte presión de venta',
      'Recuperación técnica en progreso',
      'Siguiente soporte clave',
      'Oportunidad de entrada',
    ];

    // Seleccionar veredicto basado en el símbolo (consistente)
    final index = crypto.symbol.hashCode.abs() % veredicts.length;
    return veredicts[index];
  }

  /// Calcula métricas para múltiples criptomonedas
  /// [cryptos] Lista de criptomonedas con datos actuales
  /// [previousCloses] Mapa de símbolos a precios de cierre anterior
  /// [verdicts] Mapa opcional de veredictos del LLM por símbolo
  Map<String, DailyMetrics> calculateBatchMetrics(
    List<Crypto> cryptos, {
    required Map<String, double> previousCloses,
    Map<String, String>? verdicts,
  }) {
    final Map<String, DailyMetrics> results = {};

    for (final crypto in cryptos) {
      try {
        final previousClose = previousCloses[crypto.symbol];
        if (previousClose == null) {
          // Sin precio de cierre anterior, no se puede calcular
          continue;
        }

        final verdict = verdicts?[crypto.symbol];
        final metrics = calculateDailyMetrics(
          crypto,
          previousClose: previousClose,
          verdict: verdict,
        );
        results[crypto.symbol] = metrics;
      } catch (e) {
        // Continuar con otras criptomonedas si hay error
        continue;
      }
    }

    return results;
  }

  /// Filtra criptomonedas que cumplen criterios de alerta
  List<DailyMetrics> filterAlerts(Map<String, DailyMetrics> metricsMap) {
    return metricsMap.values.where((metrics) => metrics.hasAlert).toList()
      ..sort(
        (a, b) => a.deepDrop.compareTo(b.deepDrop),
      ); // Ordenar por caída más profunda
  }

  /// Obtiene las mejores oportunidades (top N)
  List<DailyMetrics> getTopOpportunities(
    Map<String, DailyMetrics> metricsMap, {
    int limit = 5,
  }) {
    final alerts = filterAlerts(metricsMap);

    // Filtrar solo oportunidades de alta calidad
    final opportunities = alerts
        .where((metrics) => metrics.isBuyOpportunity)
        .toList();

    // Ordenar por severidad de caída y fuerza de rebote
    opportunities.sort((a, b) {
      final scoreA = _calculateOpportunityScore(a);
      final scoreB = _calculateOpportunityScore(b);
      return scoreB.compareTo(scoreA);
    });

    return opportunities.take(limit).toList();
  }

  /// Calcula un puntaje de oportunidad (interno)
  double _calculateOpportunityScore(DailyMetrics metrics) {
    final dropScore =
        metrics.dropSeverity.index.toDouble() * 2; // Más peso a caídas severas
    final reboundScore = metrics.reboundStrength.index.toDouble();
    return dropScore + reboundScore;
  }
}
