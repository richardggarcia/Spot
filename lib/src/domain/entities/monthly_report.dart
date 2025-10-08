import 'package:equatable/equatable.dart';
import 'daily_analysis.dart';
import 'weekly_summary.dart';

/// Reporte completo mensual con todas las métricas y análisis
class MonthlyReport extends Equatable {
  final String symbol;
  final String cryptoName;
  final int month; // 1-12
  final int year;
  final List<WeeklySummary> weeks;
  final List<DailyAnalysis> allDays;

  const MonthlyReport({
    required this.symbol,
    required this.cryptoName,
    required this.month,
    required this.year,
    required this.weeks,
    required this.allDays,
  });

  /// Nombre del mes en español
  String get monthName {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }

  /// Título completo del reporte
  String get title => 'Historial Detallado: $monthName $year';

  /// Máxima oportunidad del mes (día con mejor caída + rebote)
  DailyAnalysis? get maxOpportunity {
    if (allDays.isEmpty) return null;

    final alertDays = allDays.where((d) => d.hasAlert).toList();

    if (alertDays.isNotEmpty) {
      // El día con mayor caída entre los que tienen alerta
      return alertDays.reduce((a, b) => a.deepDrop < b.deepDrop ? a : b);
    }

    // Si no hay alertas, el de mayor caída
    return allDays.reduce((a, b) => a.deepDrop < b.deepDrop ? a : b);
  }

  /// Panorama general del mes
  String get panorama {
    if (maxOpportunity == null) return 'Sin datos suficientes para análisis.';

    final maxOpp = maxOpportunity!;
    final deepDropPercent = (maxOpp.deepDrop * 100).toStringAsFixed(2);
    final reboundPercent = (maxOpp.rebound * 100).toStringAsFixed(2);
    final oppPrice = maxOpp.opportunityPrice.toStringAsFixed(2);
    final oppDate = '${maxOpp.date.day} de $monthName';

    final lastWeek = weeks.isNotEmpty ? weeks.last : null;
    final lastDay = allDays.isNotEmpty ? allDays.last : null;

    String weeklyAnalysis = '';
    if (lastWeek != null) {
      final lastWeekDesc = lastWeek.description.toLowerCase();
      weeklyAnalysis =
          'La última semana (Semana ${lastWeek.weekNumber}) fue de $lastWeekDesc con baja volatilidad';

      if (lastDay != null) {
        final lastPrice = lastDay.candle.close.toStringAsFixed(2);
        weeklyAnalysis +=
            ', lo que sugiere que el mercado absorbió la caída de semanas anteriores y comenzó a consolidarse nuevamente por encima de los \$$lastPrice';
      }
      weeklyAnalysis += '.';
    }

    return '''El mes de $monthName de $year para $symbol se caracterizó por una fase de corrección ${maxOpp.hasAlert ? 'aguda pero rápida' : 'moderada'}.

La Máxima Oportunidad de Compra para el spot trader se presentó el $oppDate, cuando el precio cayó hasta \$$oppPrice (↓$deepDropPercent%). Este nivel fue defendido ${maxOpp.hasAlert ? 'fuertemente' : ''} (Rebote ↑+$reboundPercent%), lo que indica un soporte ${maxOpp.hasAlert ? 'masivo' : 'importante'} en ese precio, validando la estrategia de comprar la caída.

$weeklyAnalysis''';
  }

  /// Busca el análisis para un día específico.
  DailyAnalysis? getAnalysisForDay(DateTime day) {
    try {
      return allDays.firstWhere(
        (analysis) =>
            analysis.date.year == day.year &&
            analysis.date.month == day.month &&
            analysis.date.day == day.day,
      );
    } catch (e) {
      return null; // No se encontró el día
    }
  }

  @override
  List<Object?> get props => [symbol, cryptoName, month, year, weeks, allDays];
}
