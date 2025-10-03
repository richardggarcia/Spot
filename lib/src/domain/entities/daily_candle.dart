import 'package:equatable/equatable.dart';

/// Entidad que representa una vela diaria (OHLCV)
/// Usado para análisis histórico
class DailyCandle extends Equatable {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const DailyCandle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Calcula la caída profunda para este día
  /// Requiere el cierre del día anterior
  double calculateDeepDrop(double previousClose) {
    if (previousClose <= 0) return 0;
    return (low / previousClose) - 1;
  }

  /// Calcula el rebote (fuerza compradora) para este día
  double calculateRebound() {
    if (low <= 0) return 0;
    return (close / low) - 1;
  }

  /// Calcula el cambio neto del día (cierre vs apertura)
  double get dailyChange => (close / open) - 1;

  /// Determina si hubo alerta según criterios
  /// Caída ≤ -5% Y Rebote ≥ +3%
  bool hasAlert(double previousClose) {
    final deepDrop = calculateDeepDrop(previousClose);
    final rebound = calculateRebound();
    return deepDrop <= -0.05 && rebound >= 0.03;
  }

  @override
  List<Object?> get props => [date, open, high, low, close, volume];

  @override
  String toString() =>
      'DailyCandle(date: $date, O: $open, H: $high, L: $low, C: $close)';
}
