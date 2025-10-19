import 'dart:collection';

import '../../core/utils/logger.dart';
import '../entities/daily_analysis.dart';
import '../entities/daily_candle.dart';
import '../entities/monthly_report.dart';
import '../entities/weekly_summary.dart';

/// Servicio de dominio para generar análisis históricos
/// Procesa velas diarias y genera reportes semanales/mensuales
class HistoricalAnalysisService {

  /// Genera una lista de reportes para los últimos meses a partir de una lista de velas.
  List<MonthlyReport> generateReportsForLastMonths({
    required String symbol,
    required String cryptoName,
    required List<DailyCandle> candles,
    int monthsToGenerate = 3,
  }) {
    if (candles.isEmpty) {
      return [];
    }

    // Agrupar velas por mes y año
    final groupedByMonth = SplayTreeMap<String, List<DailyCandle>>();
    for (final candle in candles) {
      final key = '${candle.date.year}-${candle.date.month.toString().padLeft(2, '0')}';
      if (!groupedByMonth.containsKey(key)) {
        groupedByMonth[key] = [];
      }
      groupedByMonth[key]!.add(candle);
    }

    // Generar un reporte para cada mes, empezando por el más reciente
    final reports = <MonthlyReport>[];
    final sortedKeys = groupedByMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    for (var i = 0; i < sortedKeys.length && i < monthsToGenerate; i++) {
      final key = sortedKeys[i];
      final monthCandles = groupedByMonth[key]!;
      final year = int.parse(key.split('-')[0]);
      final month = int.parse(key.split('-')[1]);

      try {
        final report = generateMonthlyReport(
          symbol: symbol,
          cryptoName: cryptoName,
          candles: monthCandles, // Pasamos solo las velas del mes
          month: month,
          year: year,
        );
        reports.add(report);
      } catch (e) {
        // Ignorar meses si fallan (ej. datos incompletos)
        AppLogger.error('Error generating report for $key: $e');
      }
    }

    return reports;
  }


  /// Genera reporte mensual completo a partir de velas diarias
  MonthlyReport generateMonthlyReport({
    required String symbol,
    required String cryptoName,
    required List<DailyCandle> candles,
    int? month,
    int? year,
  }) {
    if (candles.isEmpty) {
      throw ArgumentError('No hay datos para generar reporte');
    }

    // Ordenar por fecha (más antigua primero)
    final sortedCandles = List<DailyCandle>.from(candles)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Usar mes/año del ÚLTIMO candle (más reciente) si no se especifica
    final reportMonth = month ?? sortedCandles.last.date.month;
    final reportYear = year ?? sortedCandles.last.date.year;

    // Filtrar solo candles del mes y año especificado
    final filteredCandles = sortedCandles.where((candle) => candle.date.month == reportMonth && candle.date.year == reportYear).toList();

    if (filteredCandles.isEmpty) {
      throw ArgumentError('No hay datos para el mes $reportMonth/$reportYear');
    }

    // Generar análisis diarios
    final dailyAnalyses = <DailyAnalysis>[];
    for (var i = 0; i < filteredCandles.length; i++) {
      final candle = filteredCandles[i];
      final previousClose = i > 0 ? filteredCandles[i - 1].close : candle.open;

      dailyAnalyses.add(
        DailyAnalysis.fromCandle(candle: candle, previousClose: previousClose),
      );
    }

    // Agrupar por semanas
    final weeks = _groupByWeeks(dailyAnalyses);

    return MonthlyReport(
      symbol: symbol,
      cryptoName: cryptoName,
      month: reportMonth,
      year: reportYear,
      weeks: weeks,
      allDays: dailyAnalyses,
    );
  }

  /// Agrupa análisis diarios en semanas
  List<WeeklySummary> _groupByWeeks(List<DailyAnalysis> days) {
    if (days.isEmpty) return [];

    final weeks = <WeeklySummary>[];
    final firstDate = days.first.date;

    // Determinar el inicio del mes
    final monthStart = DateTime(firstDate.year, firstDate.month);

    var currentWeekNumber = 1;
    var currentWeekDays = <DailyAnalysis>[];
    DateTime? currentWeekStart;

    for (final day in days) {
      // Calcular qué semana del mes es este día
      final daysSinceMonthStart = day.date.difference(monthStart).inDays;
      final weekNumber = (daysSinceMonthStart / 7).floor() + 1;

      if (weekNumber != currentWeekNumber && currentWeekDays.isNotEmpty) {
        // Guardar semana anterior
        weeks.add(
          WeeklySummary(
            weekNumber: currentWeekNumber,
            startDate: currentWeekStart!,
            endDate: currentWeekDays.last.date,
            days: List.from(currentWeekDays),
          ),
        );

        // Iniciar nueva semana
        currentWeekNumber = weekNumber;
        currentWeekDays = [];
        currentWeekStart = null;
      }

      currentWeekStart ??= day.date;

      currentWeekDays.add(day);
    }

    // Agregar última semana
    if (currentWeekDays.isNotEmpty) {
      weeks.add(
        WeeklySummary(
          weekNumber: currentWeekNumber,
          startDate: currentWeekStart!,
          endDate: currentWeekDays.last.date,
          days: currentWeekDays,
        ),
      );
    }

    return weeks;
  }

  /// Genera análisis de un solo día
  DailyAnalysis analyzeSingleDay({
    required DailyCandle candle,
    required double previousClose,
    String? verdict,
  }) => DailyAnalysis.fromCandle(
      candle: candle,
      previousClose: previousClose,
      verdict: verdict,
    );
}
