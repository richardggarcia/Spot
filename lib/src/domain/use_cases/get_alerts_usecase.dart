import '../entities/daily_metrics.dart';
import '../repositories/crypto_repository.dart';

/// Caso de uso para obtener alertas de trading
/// Centraliza la lógica para obtener y filtrar oportunidades
class GetAlertsUseCase {
  final CryptoRepository _cryptoRepository;

  GetAlertsUseCase(this._cryptoRepository);

  /// Ejecuta el caso de uso: obtiene todas las alertas activas
  Future<List<DailyMetrics>> execute() async {
    try {
      final metricsMap = await _cryptoRepository.calculateAllDailyMetrics();
      return _filterAlerts(metricsMap);
    } catch (e) {
      throw Exception('Error al obtener alertas: $e');
    }
  }

  /// Ejecuta el caso de uso: obtiene las mejores oportunidades
  Future<List<DailyMetrics>> executeTopOpportunities({int limit = 5}) async {
    try {
      final metricsMap = await _cryptoRepository.calculateAllDailyMetrics();
      return _getTopOpportunities(metricsMap, limit: limit);
    } catch (e) {
      throw Exception('Error al obtener oportunidades: $e');
    }
  }

  /// Filtra métricas que tienen alertas
  List<DailyMetrics> _filterAlerts(Map<String, DailyMetrics> metricsMap) {
    return metricsMap.values.where((metrics) => metrics.hasAlert).toList()
      ..sort((a, b) => a.deepDrop.compareTo(b.deepDrop));
  }

  /// Obtiene las mejores oportunidades basadas en criterios de calidad
  List<DailyMetrics> _getTopOpportunities(
    Map<String, DailyMetrics> metricsMap, {
    required int limit,
  }) {
    final alerts = _filterAlerts(metricsMap);

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

  /// Calcula puntaje de oportunidad (más alto = mejor oportunidad)
  double _calculateOpportunityScore(DailyMetrics metrics) {
    final dropScore =
        metrics.dropSeverity.index.toDouble() * 2; // Más peso a caídas severas
    final reboundScore = metrics.reboundStrength.index.toDouble();
    return dropScore + reboundScore;
  }
}
