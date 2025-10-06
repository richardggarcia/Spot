import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/daily_metrics.dart';
import '../../../domain/ports/streaming_data_port.dart';
import '../../../domain/use_cases/get_crypto_data_usecase.dart';
import '../../../domain/use_cases/get_alerts_usecase.dart';
import '../../../core/utils/logger.dart';
import 'crypto_event.dart';
import 'crypto_state.dart';

/// BLoC para manejar el estado de las criptomonedas
class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final GetCryptoDataUseCase _getCryptoDataUseCase;
  final GetAlertsUseCase _getAlertsUseCase;
  final StreamingDataPort _streamingDataPort;

  StreamSubscription? _priceSubscription;

  CryptoBloc({
    required GetCryptoDataUseCase getCryptoDataUseCase,
    required GetAlertsUseCase getAlertsUseCase,
    required StreamingDataPort streamingDataPort,
  })  : _getCryptoDataUseCase = getCryptoDataUseCase,
        _getAlertsUseCase = getAlertsUseCase,
        _streamingDataPort = streamingDataPort,
        super(CryptoInitial()) {
    on<GetAllCryptos>(_onGetAllCryptos);
    on<GetCryptoBySymbol>(_onGetCryptoBySymbol);
    on<RefreshCryptos>(_onRefreshCryptos);
    on<RefreshCrypto>(_onRefreshCrypto);
    on<GetAllCryptosWithMetrics>(_onGetAllCryptosWithMetrics);
    on<StartRealtimeUpdates>(_onStartRealtimeUpdates);
    on<StopRealtimeUpdates>(_onStopRealtimeUpdates);
    on<PriceTickReceived>(_onPriceTickReceived);
  }

  @override
  Future<void> close() {
    _priceSubscription?.cancel();
    _streamingDataPort.disconnect();
    return super.close();
  }

  void _onStartRealtimeUpdates(
    StartRealtimeUpdates event,
    Emitter<CryptoState> emit,
  ) {
    AppLogger.info('Starting real-time price updates...');
    // Cancelar cualquier subscripción anterior para evitar duplicados
    _priceSubscription?.cancel();
    _priceSubscription = _streamingDataPort.connect(event.symbols).listen(
      (tick) {
        // Añadir un evento interno al BLoC para procesar el tick
        add(PriceTickReceived(tick));
      },
      onError: (error) {
        AppLogger.error('Error in price stream', error);
        // Opcional: emitir un estado de error de stream
      },
    );
  }

  void _onStopRealtimeUpdates(
    StopRealtimeUpdates event,
    Emitter<CryptoState> emit,
  ) {
    AppLogger.info('Stopping real-time price updates...');
    _priceSubscription?.cancel();
    _streamingDataPort.disconnect();
  }

  void _onPriceTickReceived(
    PriceTickReceived event,
    Emitter<CryptoState> emit,
  ) {
    // Solo actualizar si el estado actual contiene la lista de cryptos
    final currentState = state;
    if (currentState is! CryptoWithMetricsLoaded) return;

    // Crear una nueva lista de cryptos con el precio actualizado
    final updatedCryptos = currentState.cryptos.map((crypto) {
      if (crypto.symbol == event.tick.symbol) {
        // Usar copyWith para crear una nueva instancia inmutable
        return crypto.copyWith(
          currentPrice: event.tick.price,
          lastUpdated: event.tick.timestamp,
        );
      }
      return crypto;
    }).toList();

    // Emitir el nuevo estado con la lista actualizada
    emit(CryptoWithMetricsLoaded(
      cryptos: updatedCryptos,
      metrics: currentState.metrics,
    ));
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
    }
    catch (e) {
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

      // 1. Obtener cryptos primero (rápido)
      final cryptos = await _getCryptoDataUseCase.execute();

      // 2. Emitir estado con cryptos pero métricas vacías
      // Esto permite que la UI se muestre inmediatamente
      emit(CryptoWithMetricsLoaded(cryptos: cryptos, metrics: {}));

      AppLogger.info('Se cargaron ${cryptos.length} criptomonedas, calculando métricas...');

      // 3. Obtener métricas en background (las llamadas ya son paralelas en el repositorio)
      final metrics = await _getAlertsUseCase.executeAllMetrics();

      // 4. Convertir lista de métricas a mapa por símbolo
      final metricsMap = <String, DailyMetrics>{};
      for (final metric in metrics) {
        metricsMap[metric.crypto.symbol] = metric;
      }

      // 5. Emitir estado final con métricas
      emit(CryptoWithMetricsLoaded(cryptos: cryptos, metrics: metricsMap));

      AppLogger.info(
        'Se cargaron ${cryptos.length} criptomonedas con ${metricsMap.length} métricas',
      );
    } catch (e) {
      AppLogger.error('Error al obtener criptomonedas con métricas', e);
      emit(CryptoError('Error al cargar datos con métricas: $e'));
    }
  }
}
