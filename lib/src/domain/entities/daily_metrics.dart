import 'package:equatable/equatable.dart';
import 'crypto.dart';

/// Entidad de dominio para métricas diarias de trading
/// Contiene toda la lógica de cálculo y alertas
class DailyMetrics extends Equatable {

  const DailyMetrics({
    required this.crypto,
    required this.deepDrop,
    required this.rebound,
    required this.hasAlert,
    this.verdict,
    required this.calculatedAt,
  });
  final Crypto crypto;
  final double deepDrop; // Caída profunda: (min/previousClose) - 1
  final double rebound; // Rebote: (current/min) - 1
  final bool hasAlert; // Alerta si caída <= -5% y rebote >= +3%
  final String? verdict; // Veredicto del LLM/mock
  final DateTime calculatedAt;

  /// Formatea la caída profunda para display
  String get formattedDeepDrop {
    final percentage = deepDrop * 100;
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(2)}%';
  }

  /// Formatea el rebote para display
  String get formattedRebound {
    final percentage = rebound * 100;
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(2)}%';
  }

  /// Obtiene el nivel de severidad de la caída
  DropSeverity get dropSeverity {
    if (deepDrop <= -0.10) return DropSeverity.severe;
    if (deepDrop <= -0.07) return DropSeverity.high;
    if (deepDrop <= -0.05) return DropSeverity.moderate;
    if (deepDrop <= -0.03) return DropSeverity.low;
    return DropSeverity.minimal;
  }

  /// Obtiene el nivel de fuerza del rebote
  ReboundStrength get reboundStrength {
    if (rebound >= 0.10) return ReboundStrength.strong;
    if (rebound >= 0.07) return ReboundStrength.high;
    if (rebound >= 0.05) return ReboundStrength.moderate;
    if (rebound >= 0.03) return ReboundStrength.low;
    return ReboundStrength.weak;
  }

  /// Verifica si es una oportunidad de compra según criterios estrictos
  bool get isBuyOpportunity =>
      hasAlert && dropSeverity.index >= DropSeverity.moderate.index;

  /// Calcula el precio teórico de entrada (con margen de seguridad)
  double get suggestedEntryPrice =>
      crypto.low24h * 0.98; // 2% debajo del mínimo

  /// Calcula el precio objetivo de salida (10% por encima de entrada)
  double get suggestedExitPrice => suggestedEntryPrice * 1.10;

  @override
  List<Object?> get props => [
    crypto,
    deepDrop,
    rebound,
    hasAlert,
    verdict,
    calculatedAt,
  ];

  @override
  String toString() =>
      'DailyMetrics(${crypto.symbol}: drop=$formattedDeepDrop, rebound=$formattedRebound)';

  /// Crea una copia con valores actualizados
  DailyMetrics copyWith({
    Crypto? crypto,
    double? deepDrop,
    double? rebound,
    bool? hasAlert,
    String? verdict,
    DateTime? calculatedAt,
  }) => DailyMetrics(
      crypto: crypto ?? this.crypto,
      deepDrop: deepDrop ?? this.deepDrop,
      rebound: rebound ?? this.rebound,
      hasAlert: hasAlert ?? this.hasAlert,
      verdict: verdict ?? this.verdict,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
}

/// Enum para niveles de caída
enum DropSeverity {
  minimal, // < 3%
  low, // 3% - 5%
  moderate, // 5% - 7%
  high, // 7% - 10%
  severe, // > 10%
}

/// Enum para fuerza de rebote
enum ReboundStrength {
  weak, // < 3%
  low, // 3% - 5%
  moderate, // 5% - 7%
  high, // 7% - 10%
  strong, // > 10%
}
