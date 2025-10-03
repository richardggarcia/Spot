import 'package:equatable/equatable.dart';

/// Entidad de dominio para una criptomoneda
/// Contiene solo la lógica de negocio, sin dependencias externas
class Crypto extends Equatable {
  final String symbol;
  final String name;
  final double currentPrice;
  final double priceChange24h;
  final double priceChangePercent24h;
  final double high24h;
  final double low24h;
  final double open24h;
  final double volume24h;
  final DateTime lastUpdated;

  const Crypto({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChangePercent24h,
    required this.high24h,
    required this.low24h,
    required this.open24h,
    required this.volume24h,
    required this.lastUpdated,
  });

  /// Calcula el precio de cierre anterior estimado
  double get previousClose => open24h;

  /// Formatea el precio actual para display
  String get formattedPrice => _formatPrice(currentPrice);

  /// Formatea el cambio porcentual para display
  String get formattedChangePercent {
    final change = priceChangePercent24h;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(2)}%';
  }

  /// Verifica si el precio está en alza
  bool get isPositive => priceChange24h >= 0;

  /// Verifica si el precio está en baja
  bool get isNegative => priceChange24h < 0;

  /// Calcula el rango de precio del día
  double get dailyRange => high24h - low24h;

  /// Calcula la volatilidad del día (rango / precio actual)
  double get dailyVolatility => (dailyRange / currentPrice) * 100;

  @override
  List<Object?> get props => [
    symbol,
    name,
    currentPrice,
    priceChange24h,
    priceChangePercent24h,
    high24h,
    low24h,
    open24h,
    volume24h,
    lastUpdated,
  ];

  @override
  String toString() => 'Crypto($symbol: $formattedPrice)';

  /// Formateo privado de precios
  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  /// Crea una copia con valores actualizados
  Crypto copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? priceChange24h,
    double? priceChangePercent24h,
    double? high24h,
    double? low24h,
    double? open24h,
    double? volume24h,
    DateTime? lastUpdated,
  }) {
    return Crypto(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      priceChangePercent24h:
          priceChangePercent24h ?? this.priceChangePercent24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      open24h: open24h ?? this.open24h,
      volume24h: volume24h ?? this.volume24h,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
