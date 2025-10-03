import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de alertas
abstract class AlertsEvent extends Equatable {
  const AlertsEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para obtener todas las alertas
class GetAllAlerts extends AlertsEvent {
  const GetAllAlerts();
}

/// Evento para obtener las mejores oportunidades
class GetTopOpportunities extends AlertsEvent {
  final int limit;

  const GetTopOpportunities({this.limit = 5});

  @override
  List<Object?> get props => [limit];
}

/// Evento para refrescar las alertas
class RefreshAlerts extends AlertsEvent {
  const RefreshAlerts();
}
