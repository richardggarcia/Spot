import 'dart:async';

/// Representa un tick de precio en tiempo real recibido del stream.
class RealtimePriceTick {

  RealtimePriceTick({
    required this.symbol,
    required this.price,
    required this.timestamp,
  });
  final String symbol;
  final double price;
  final DateTime timestamp;

  @override
  String toString() => 'Tick for $symbol: \$$price @ $timestamp';
}

/// Port (Interface) para servicios de datos en tiempo real (streaming).
///
/// Permite que la lógica de dominio reciba datos en tiempo real sin
/// conocer la implementación específica (e.g., WebSockets, etc.).
abstract class StreamingDataPort {
  /// Inicia la conexión y se suscribe a los símbolos proporcionados.
  ///
  /// Retorna un [Stream] que emite [RealtimePriceTick] para cada actualización
  /// de precio recibida.
  ///
  /// Lanza una [Exception] si la conexión o suscripción falla.
  Stream<RealtimePriceTick> connect(List<String> symbols);

  /// Cierra la conexión del stream.
  void disconnect();
}
