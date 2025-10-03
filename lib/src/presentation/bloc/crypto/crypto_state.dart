import 'package:equatable/equatable.dart';
import '../../../domain/entities/crypto.dart';
import '../../../domain/entities/daily_metrics.dart';

/// Estados para el BLoC de criptomonedas
abstract class CryptoState extends Equatable {
  const CryptoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CryptoInitial extends CryptoState {
  const CryptoInitial();
}

/// Estado cargando
class CryptoLoading extends CryptoState {
  const CryptoLoading();
}

/// Estado cargado con lista de criptomonedas
class CryptoLoaded extends CryptoState {
  final List<Crypto> cryptos;

  const CryptoLoaded(this.cryptos);

  @override
  List<Object?> get props => [cryptos];
}

/// Estado refrescando
class CryptoRefreshing extends CryptoState {
  final List<Crypto> cryptos;

  const CryptoRefreshing(this.cryptos);

  @override
  List<Object?> get props => [cryptos];
}

/// Estado cargado con criptomonedas y métricas
class CryptoWithMetricsLoaded extends CryptoState {
  final List<Crypto> cryptos;
  final Map<String, DailyMetrics> metrics;

  const CryptoWithMetricsLoaded({required this.cryptos, required this.metrics});

  @override
  List<Object?> get props => [cryptos, metrics];
}

/// Estado de error
class CryptoError extends CryptoState {
  final String message;

  const CryptoError(this.message);

  @override
  List<Object?> get props => [message];
}
