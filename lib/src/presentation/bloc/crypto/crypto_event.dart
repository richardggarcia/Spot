import 'package:equatable/equatable.dart';

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
  final String symbol;

  const GetCryptoBySymbol(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Evento para refrescar todas las criptomonedas
class RefreshCryptos extends CryptoEvent {
  const RefreshCryptos();
}

/// Evento para refrescar una criptomoneda específica
class RefreshCrypto extends CryptoEvent {
  final String symbol;

  const RefreshCrypto(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

/// Evento para obtener todas las criptomonedas con métricas
class GetAllCryptosWithMetrics extends CryptoEvent {
  const GetAllCryptosWithMetrics();
}
