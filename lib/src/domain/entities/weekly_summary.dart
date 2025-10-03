import 'package:equatable/equatable.dart';
import 'daily_analysis.dart';

/// Resumen semanal de volatilidad y oportunidades
class WeeklySummary extends Equatable {
  final int weekNumber; // Semana 1, 2, 3, 4
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyAnalysis> days;

  const WeeklySummary({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  /// Mayor caída profunda de la semana
  double get maxDeepDrop {
    if (days.isEmpty) return 0;
    return days.map((d) => d.deepDrop).reduce((a, b) => a < b ? a : b);
  }

  /// Rebote promedio semanal
  double get averageRebound {
    if (days.isEmpty) return 0;
    final sum = days.map((d) => d.rebound).reduce((a, b) => a + b);
    return sum / days.length;
  }

  /// Punto de compra clave (día con mejor caída + rebote)
  DailyAnalysis? get keyBuyingPoint {
    if (days.isEmpty) return null;

    // Buscar el día con alerta o la mayor caída profunda
    final alertDays = days.where((d) => d.hasAlert).toList();

    if (alertDays.isNotEmpty) {
      // Retornar el de mayor caída entre los que tienen alerta
      return alertDays.reduce((a, b) => a.deepDrop < b.deepDrop ? a : b);
    }

    // Si no hay alertas, retornar el de mayor caída
    return days.reduce((a, b) => a.deepDrop < b.deepDrop ? a : b);
  }

  /// Precio del punto de compra clave
  double? get keyBuyingPrice => keyBuyingPoint?.opportunityPrice;

  /// Descripción de la semana
  String get description {
    if (maxDeepDrop <= -0.05) {
      return 'Oportunidad de Caída';
    } else if (maxDeepDrop <= -0.03) {
      return 'Volatilidad Media';
    } else if (maxDeepDrop <= -0.015) {
      return 'Consolidación';
    } else {
      return 'Baja Volatilidad';
    }
  }

  @override
  List<Object?> get props => [weekNumber, startDate, endDate, days];
}
