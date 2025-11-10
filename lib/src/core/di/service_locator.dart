import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../domain/ports/price_data_port.dart';
import '../../domain/ports/streaming_data_port.dart';
import '../../domain/ports/trade_journal_port.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/trade_journal_repository.dart';
import '../../domain/services/trading_calculator.dart';
import '../../domain/use_cases/create_trade_note_usecase.dart';
import '../../domain/use_cases/delete_trade_note_usecase.dart';
import '../../domain/use_cases/get_alerts_usecase.dart';
import '../../domain/use_cases/get_crypto_data_usecase.dart';
import '../../domain/use_cases/get_trade_notes_usecase.dart';
import '../../domain/use_cases/update_trade_note_usecase.dart';
import '../../infrastructure/adapters/binance_price_adapter.dart';
import '../../infrastructure/adapters/coingecko_price_adapter.dart';
import '../../infrastructure/adapters/hybrid_price_adapter.dart';
import '../../infrastructure/adapters/logo_enrichment_adapter.dart';
import '../../infrastructure/adapters/mock_price_adapter.dart';
import '../../infrastructure/repositories/crypto_repository_impl.dart';
import '../../infrastructure/repositories/trade_journal_repository_impl.dart';
import '../../infrastructure/services/trade_journal_remote_service.dart';
import '../../infrastructure/services/user_preferences_remote_service.dart';
import '../../infrastructure/streaming/binance_streaming_service.dart';
import '../../presentation/bloc/crypto/crypto_bloc.dart';
import '../../presentation/bloc/journal/journal_bloc.dart';
import '../../presentation/managers/card_position_manager.dart';
import '../utils/crypto_preferences.dart';

/// Configuración de inyección de dependencias
/// Implementa arquitectura hexagonal con Ports y Adapters
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static GetIt get instance => _getIt;

  /// Configura todas las dependencias
  static Future<void> setup({String? coinGeckoApiKey}) async {
    // Obtener configuración del backend desde variables de entorno
    final journalApiKey = dotenv.env['SPOT_JOURNAL_API_KEY'] ?? '';
    final journalBaseUrl = dotenv.env['SPOT_JOURNAL_BASE_URL'];
    const userId = 'richard'; // Usuario configurado

    // Configurar servicio remoto de preferencias antes de cargar cryptos
    final dio = Dio(
      BaseOptions(
        baseUrl: journalBaseUrl ?? 'https://spot.bitsdeve.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (journalApiKey.isNotEmpty) 'X-API-Key': journalApiKey,
          if (journalApiKey.isNotEmpty) 'Authorization': 'Bearer $journalApiKey',
        },
      ),
    );
    final preferencesService = UserPreferencesRemoteService(
      dio: dio,
      userId: userId,
    );
    CryptoPreferences.configureRemoteService(preferencesService);
    CardPositionManager.configureRemoteService(preferencesService);

    // Obtener cryptos seleccionadas por el usuario (ahora puede cargar del backend)
    final selectedCryptos = await CryptoPreferences.getSelectedCryptos();

    _getIt
      // Core
      ..registerLazySingleton<Logger>(Logger.new)
      // Constants - ahora dinámico basado en preferencias del usuario
      ..registerLazySingleton<List<String>>(() => selectedCryptos)
      // Domain Services
      ..registerLazySingleton<TradingCalculator>(TradingCalculator.new)
      // --- Adapters (Ports implementations) ---
      // Adapter de CoinGecko (se usará para enriquecer logos)
      ..registerLazySingleton<CoinGeckoPriceAdapter>(
        () => CoinGeckoPriceAdapter(apiKey: coinGeckoApiKey),
      )
      // Adapter para enriquecer con logos
      ..registerLazySingleton<LogoEnrichmentAdapter>(
        () => LogoEnrichmentAdapter(_getIt<CoinGeckoPriceAdapter>()),
      )
      // 1. Price Data Port (Hybrid Adapter)
      ..registerLazySingleton<PriceDataPort>(
        () => HybridPriceAdapter(
          primaryAdapter: BinancePriceAdapter(),
          backupAdapter: _getIt<CoinGeckoPriceAdapter>(),
          mockAdapter: MockPriceAdapter(), // Fallback para CORS issues
        ),
      )
      // 2. Streaming Data Port (WebSocket)
      ..registerLazySingleton<StreamingDataPort>(BinanceStreamingService.new)
      ..registerLazySingleton<TradeJournalPort>(
        () => TradeJournalRemoteService(
          apiKey: journalApiKey,
          baseUrl: journalBaseUrl,
        ),
      )
      // --- Repositories ---
      ..registerLazySingleton<CryptoRepository>(
        () => CryptoRepositoryImpl(
          priceDataPort: _getIt<PriceDataPort>(),
          logoEnrichmentAdapter: _getIt<LogoEnrichmentAdapter>(),
          calculator: _getIt<TradingCalculator>(),
          monitoredSymbols: _getIt<List<String>>(),
        ),
      )
      ..registerLazySingleton<TradeJournalRepository>(
        () =>
            TradeJournalRepositoryImpl(journalPort: _getIt<TradeJournalPort>()),
      )
      // --- Use Cases ---
      ..registerLazySingleton<GetCryptoDataUseCase>(
        () => GetCryptoDataUseCase(_getIt<CryptoRepository>()),
      )
      ..registerLazySingleton<GetAlertsUseCase>(
        () => GetAlertsUseCase(_getIt<CryptoRepository>()),
      )
      ..registerLazySingleton<GetTradeNotesUseCase>(
        () => GetTradeNotesUseCase(_getIt<TradeJournalRepository>()),
      )
      ..registerLazySingleton<CreateTradeNoteUseCase>(
        () => CreateTradeNoteUseCase(_getIt<TradeJournalRepository>()),
      )
      ..registerLazySingleton<UpdateTradeNoteUseCase>(
        () => UpdateTradeNoteUseCase(_getIt<TradeJournalRepository>()),
      )
      ..registerLazySingleton<DeleteTradeNoteUseCase>(
        () => DeleteTradeNoteUseCase(_getIt<TradeJournalRepository>()),
      )
      // --- BLoCs ---
      ..registerFactory<CryptoBloc>(
        () => CryptoBloc(
          getCryptoDataUseCase: _getIt<GetCryptoDataUseCase>(),
          getAlertsUseCase: _getIt<GetAlertsUseCase>(),
          streamingDataPort: _getIt<StreamingDataPort>(),
        ),
      )
      ..registerFactory<JournalBloc>(
        () => JournalBloc(
          getTradeNotesUseCase: _getIt<GetTradeNotesUseCase>(),
          createTradeNoteUseCase: _getIt<CreateTradeNoteUseCase>(),
          updateTradeNoteUseCase: _getIt<UpdateTradeNoteUseCase>(),
          deleteTradeNoteUseCase: _getIt<DeleteTradeNoteUseCase>(),
        ),
      );
  }

  /// Limpia todas las dependencias (para testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }

  /// Registra una dependencia
  static void registerSingleton<T extends Object>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }

  /// Registra una dependencia lazy
  static void registerLazySingleton<T extends Object>(
    T Function() factoryFunc,
  ) {
    _getIt.registerLazySingleton<T>(factoryFunc);
  }

  /// Obtiene una dependencia
  static T get<T extends Object>() => _getIt<T>();

  /// Verifica si una dependencia está registrada
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}
