import 'package:equatable/equatable.dart';
import '../../../domain/ports/streaming_data_port.dart';

/// Eventos para el BLoC de criptomonedas
abstract class CryptoEvent extends Equatable {
  const CryptoEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para obtener todas las criptomonedas
class GetAllCryptos extends CryptoEvent {
  const GetAllCryptos();
}

/// Evento para obtener una criptomoneda específica
class GetCryptoBySymbol extends CryptoEvent {

  const GetCryptoBySymbol(this.symbol);
  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

/// Evento para refrescar todas las criptomonedas
class RefreshCryptos extends CryptoEvent {
  const RefreshCryptos();
}

/// Evento para refrescar una criptomoneda específica
class RefreshCrypto extends CryptoEvent {

  const RefreshCrypto(this.symbol);
  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

/// Evento para obtener todas las criptomonedas con métricas
class GetAllCryptosWithMetrics extends CryptoEvent {
  const GetAllCryptosWithMetrics();
}

// --- Eventos para WebSocket ---

/// Inicia la conexión WebSocket para recibir actualizaciones en tiempo real.
class StartRealtimeUpdates extends CryptoEvent {

  const StartRealtimeUpdates(this.symbols);
  final List<String> symbols;

  @override
  List<Object?> get props => [symbols];
}

/// Detiene la conexión WebSocket.
class StopRealtimeUpdates extends CryptoEvent {
  const StopRealtimeUpdates();
}

/// Evento interno para procesar un tick de precio recibido.
class PriceTickReceived extends CryptoEvent {

  const PriceTickReceived(this.tick);
  final RealtimePriceTick tick;

  @override
  List<Object?> get props => [tick];
}
