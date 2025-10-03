import 'package:equatable/equatable.dart';
import 'daily_candle.dart';

/// Análisis completo de un día con todas las métricas calculadas
class DailyAnalysis extends Equatable {
  final DateTime date;
  final String weekday; // Lunes, Martes, etc.
  final DailyCandle candle;
  final double previousClose;

  // Métricas calculadas
  final double deepDrop; // Caída Profunda (↓)
  final double rebound; // Rebote (↑)
  final double netChange; // Cierre Neto (24h)
  final bool hasAlert; // Si cumple criterios de alerta
  final String verdict; // Veredicto clave

  const DailyAnalysis({
    required this.date,
    required this.weekday,
    required this.candle,
    required this.previousClose,
    required this.deepDrop,
    required this.rebound,
    required this.netChange,
    required this.hasAlert,
    required this.verdict,
  });

  /// Precio de oportunidad (mínimo del día)
  double get opportunityPrice => candle.low;

  /// Factory para crear desde un candle
  factory DailyAnalysis.fromCandle({
    required DailyCandle candle,
    required double previousClose,
    String? verdict,
  }) {
    final deepDrop = candle.calculateDeepDrop(previousClose);
    final rebound = candle.calculateRebound();
    final netChange = (candle.close / previousClose) - 1;
    final hasAlert = deepDrop <= -0.05 && rebound >= 0.03;

    // Veredicto automático si no se provee
    final autoVerdict =
        verdict ?? _generateVerdict(deepDrop, rebound, netChange);

    // Obtener día de la semana en español
    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final weekday = weekdays[candle.date.weekday - 1];

    return DailyAnalysis(
      date: candle.date,
      weekday: weekday,
      candle: candle,
      previousClose: previousClose,
      deepDrop: deepDrop,
      rebound: rebound,
      netChange: netChange,
      hasAlert: hasAlert,
      verdict: autoVerdict,
    );
  }

  /// Genera veredicto automático basado en las métricas
  static String _generateVerdict(
    double deepDrop,
    double rebound,
    double netChange,
  ) {
    if (deepDrop <= -0.06 && rebound >= 0.05) {
      return '¡ALERTA MÁXIMA! Soporte defendido agresivamente';
    } else if (deepDrop <= -0.05 && rebound >= 0.03) {
      return 'Fuerte presión bajista defendida';
    } else if (deepDrop <= -0.04) {
      return 'Corrección moderada';
    } else if (deepDrop <= -0.02) {
      return 'Presión de venta';
    } else if (rebound >= 0.03) {
      return 'Rebote de confirmación';
    } else if (netChange >= 0.02) {
      return 'Tendencia alcista';
    } else if (netChange >= 0.01) {
      return 'Continuación de la subida';
    } else if (netChange <= -0.02) {
      return 'Inicio de corrección';
    } else if (netChange <= -0.01) {
      return 'Pausa en la subida';
    } else if (deepDrop >= -0.01 && rebound <= 0.01) {
      return 'Volatilidad muy baja';
    } else {
      return 'Estable';
    }
  }

  @override
  List<Object?> get props => [
    date,
    weekday,
    candle,
    previousClose,
    deepDrop,
    rebound,
    netChange,
    hasAlert,
    verdict,
  ];
}
