import 'package:equatable/equatable.dart';
import '../../../domain/entities/daily_metrics.dart';

/// Estados para el BLoC de alertas
abstract class AlertsState extends Equatable {
  const AlertsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AlertsInitial extends AlertsState {
  const AlertsInitial();
}

/// Estado cargando
class AlertsLoading extends AlertsState {
  const AlertsLoading();
}

/// Estado cargado con alertas
class AlertsLoaded extends AlertsState {
  final List<DailyMetrics> alerts;
  final List<DailyMetrics> topOpportunities;

  const AlertsLoaded({required this.alerts, required this.topOpportunities});

  @override
  List<Object?> get props => [alerts, topOpportunities];
}

/// Estado refrescando
class AlertsRefreshing extends AlertsState {
  final List<DailyMetrics> alerts;
  final List<DailyMetrics> topOpportunities;

  const AlertsRefreshing({
    required this.alerts,
    required this.topOpportunities,
  });

  @override
  List<Object?> get props => [alerts, topOpportunities];
}

/// Estado sin alertas
class NoAlerts extends AlertsState {
  const NoAlerts();
}

/// Estado de error
class AlertsError extends AlertsState {
  final String message;

  const AlertsError(this.message);

  @override
  List<Object?> get props => [message];
}
