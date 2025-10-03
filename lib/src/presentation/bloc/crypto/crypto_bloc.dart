import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/daily_metrics.dart';
import '../../../domain/use_cases/get_crypto_data_usecase.dart';
import '../../../domain/use_cases/get_alerts_usecase.dart';
import '../../../core/utils/logger.dart';
import 'crypto_event.dart';
import 'crypto_state.dart';

/// BLoC para manejar el estado de las criptomonedas
class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final GetCryptoDataUseCase _getCryptoDataUseCase;
  final GetAlertsUseCase _getAlertsUseCase;

  CryptoBloc({
    required GetCryptoDataUseCase getCryptoDataUseCase,
    required GetAlertsUseCase getAlertsUseCase,
  }) : _getCryptoDataUseCase = getCryptoDataUseCase,
       _getAlertsUseCase = getAlertsUseCase,
       super(CryptoInitial()) {
    on<GetAllCryptos>(_onGetAllCryptos);
    on<GetCryptoBySymbol>(_onGetCryptoBySymbol);
    on<RefreshCryptos>(_onRefreshCryptos);
    on<RefreshCrypto>(_onRefreshCrypto);
    on<GetAllCryptosWithMetrics>(_onGetAllCryptosWithMetrics);
  }

  Future<void> _onGetAllCryptos(
    GetAllCryptos event,
    Emitter<CryptoState> emit,
  ) async {
    emit(CryptoLoading());
    try {
      AppLogger.info('Obteniendo todas las criptomonedas');
      final cryptos = await _getCryptoDataUseCase.execute();
      emit(CryptoLoaded(cryptos));
      AppLogger.info('Se cargaron ${cryptos.length} criptomonedas');
    } catch (e) {
      AppLogger.error('Error al obtener criptomonedas', e);
      emit(CryptoError('Error al cargar datos: $e'));
    }
  }

  Future<void> _onGetCryptoBySymbol(
    GetCryptoBySymbol event,
    Emitter<CryptoState> emit,
  ) async {
    if (state is! CryptoLoaded) {
      emit(CryptoLoading());
    }

    try {
      AppLogger.info('Obteniendo criptomoneda: ${event.symbol}');
      final crypto = await _getCryptoDataUseCase.executeBySymbol(event.symbol);

      if (crypto != null) {
        if (state is CryptoLoaded) {
          final currentCryptos = (state as CryptoLoaded).cryptos;
          final updatedCryptos = currentCryptos
              .map((c) => c.symbol == event.symbol ? crypto : c)
              .toList();

          if (!currentCryptos.any((c) => c.symbol == event.symbol)) {
            updatedCryptos.add(crypto);
          }

          emit(CryptoLoaded(updatedCryptos));
        } else {
          emit(CryptoLoaded([crypto]));
        }
        AppLogger.info('Se actualizó ${event.symbol}');
      } else {
        AppLogger.warning('No se encontró ${event.symbol}');
      }
    } catch (e) {
      AppLogger.error('Error al obtener ${event.symbol}', e);
      emit(CryptoError('Error al cargar $event.symbol: $e'));
    }
  }

  Future<void> _onRefreshCryptos(
    RefreshCryptos event,
    Emitter<CryptoState> emit,
  ) async {
    if (state is CryptoLoaded) {
      emit(CryptoRefreshing((state as CryptoLoaded).cryptos));
    } else {
      emit(CryptoLoading());
    }

    try {
      AppLogger.info('Refrescando todas las criptomonedas');
      final cryptos = await _getCryptoDataUseCase.executeRefresh();
      emit(CryptoLoaded(cryptos));
      AppLogger.info('Se refrescaron ${cryptos.length} criptomonedas');
    } catch (e) {
      AppLogger.error('Error al refrescar criptomonedas', e);
      if (state is CryptoRefreshing) {
        emit(CryptoLoaded((state as CryptoRefreshing).cryptos));
      } else {
        emit(CryptoError('Error al refrescar datos: $e'));
      }
    }
  }

  Future<void> _onRefreshCrypto(
    RefreshCrypto event,
    Emitter<CryptoState> emit,
  ) async {
    if (state is! CryptoLoaded) return;

    try {
      AppLogger.info('Refrescando criptomoneda: ${event.symbol}');
      final crypto = await _getCryptoDataUseCase.executeBySymbol(event.symbol);

      if (crypto != null) {
        final currentCryptos = (state as CryptoLoaded).cryptos;
        final updatedCryptos = currentCryptos
            .map((c) => c.symbol == event.symbol ? crypto : c)
            .toList();

        emit(CryptoLoaded(updatedCryptos));
        AppLogger.info('Se refrescó ${event.symbol}');
      }
    } catch (e) {
      AppLogger.error('Error al refrescar ${event.symbol}', e);
      // No cambiamos el estado en caso de error de refresh individual
    }
  }

  Future<void> _onGetAllCryptosWithMetrics(
    GetAllCryptosWithMetrics event,
    Emitter<CryptoState> emit,
  ) async {
    emit(CryptoLoading());
    try {
      AppLogger.info('Obteniendo criptomonedas con métricas');

      // Obtener cryptos
      final cryptos = await _getCryptoDataUseCase.execute();

      // Obtener métricas para todas las cryptos
      final metrics = await _getAlertsUseCase.execute();

      // Convertir lista de métricas a mapa por símbolo
      final metricsMap = <String, DailyMetrics>{};
      for (final metric in metrics) {
        metricsMap[metric.crypto.symbol] = metric;
      }

      emit(CryptoWithMetricsLoaded(cryptos: cryptos, metrics: metricsMap));

      AppLogger.info(
        'Se cargaron ${cryptos.length} criptomonedas con métricas',
      );
    } catch (e) {
      AppLogger.error('Error al obtener criptomonedas con métricas', e);
      emit(CryptoError('Error al cargar datos con métricas: $e'));
    }
  }
}
