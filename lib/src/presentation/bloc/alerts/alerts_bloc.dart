import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/get_alerts_usecase.dart';
import '../../../core/utils/logger.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

/// BLoC para manejar el estado de las alertas
class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final GetAlertsUseCase _getAlertsUseCase;

  AlertsBloc({required GetAlertsUseCase getAlertsUseCase})
    : _getAlertsUseCase = getAlertsUseCase,
      super(AlertsInitial()) {
    on<GetAllAlerts>(_onGetAllAlerts);
    on<GetTopOpportunities>(_onGetTopOpportunities);
    on<RefreshAlerts>(_onRefreshAlerts);
  }

  Future<void> _onGetAllAlerts(
    GetAllAlerts event,
    Emitter<AlertsState> emit,
  ) async {
    emit(AlertsLoading());
    try {
      AppLogger.info('Obteniendo todas las alertas');
      final alerts = await _getAlertsUseCase.execute();

      if (alerts.isEmpty) {
        emit(NoAlerts());
        AppLogger.info('No se encontraron alertas activas');
      } else {
        final topOpportunities = await _getAlertsUseCase
            .executeTopOpportunities();
        emit(AlertsLoaded(alerts: alerts, topOpportunities: topOpportunities));
        AppLogger.info('Se cargaron ${alerts.length} alertas');
      }
    } catch (e) {
      AppLogger.error('Error al obtener alertas', e);
      emit(AlertsError('Error al cargar alertas: $e'));
    }
  }

  Future<void> _onGetTopOpportunities(
    GetTopOpportunities event,
    Emitter<AlertsState> emit,
  ) async {
    emit(AlertsLoading());
    try {
      AppLogger.info(
        'Obteniendo mejores oportunidades (límite: ${event.limit})',
      );
      final opportunities = await _getAlertsUseCase.executeTopOpportunities(
        limit: event.limit,
      );

      if (opportunities.isEmpty) {
        emit(NoAlerts());
        AppLogger.info('No se encontraron oportunidades');
      } else {
        final allAlerts = await _getAlertsUseCase.execute();
        emit(AlertsLoaded(alerts: allAlerts, topOpportunities: opportunities));
        AppLogger.info('Se cargaron ${opportunities.length} oportunidades');
      }
    } catch (e) {
      AppLogger.error('Error al obtener oportunidades', e);
      emit(AlertsError('Error al cargar oportunidades: $e'));
    }
  }

  Future<void> _onRefreshAlerts(
    RefreshAlerts event,
    Emitter<AlertsState> emit,
  ) async {
    if (state is AlertsLoaded) {
      final currentState = state as AlertsLoaded;
      emit(
        AlertsRefreshing(
          alerts: currentState.alerts,
          topOpportunities: currentState.topOpportunities,
        ),
      );
    } else {
      emit(AlertsLoading());
    }

    try {
      AppLogger.info('Refrescando alertas');
      final alerts = await _getAlertsUseCase.execute();
      final topOpportunities = await _getAlertsUseCase
          .executeTopOpportunities();

      if (alerts.isEmpty) {
        emit(NoAlerts());
      } else {
        emit(AlertsLoaded(alerts: alerts, topOpportunities: topOpportunities));
      }
      AppLogger.info('Se refrescaron las alertas');
    } catch (e) {
      AppLogger.error('Error al refrescar alertas', e);

      if (state is AlertsRefreshing) {
        final refreshingState = state as AlertsRefreshing;
        emit(
          AlertsLoaded(
            alerts: refreshingState.alerts,
            topOpportunities: refreshingState.topOpportunities,
          ),
        );
      } else {
        emit(AlertsError('Error al refrescar alertas: $e'));
      }
    }
  }
}
