import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../domain/ports/price_data_port.dart';
import '../../domain/ports/streaming_data_port.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/services/trading_calculator.dart';
import '../../domain/use_cases/get_alerts_usecase.dart';
import '../../domain/use_cases/get_crypto_data_usecase.dart';
import '../../infrastructure/adapters/binance_price_adapter.dart';
import '../../infrastructure/adapters/coingecko_price_adapter.dart';
import '../../infrastructure/adapters/hybrid_price_adapter.dart';
import '../../infrastructure/adapters/logo_enrichment_adapter.dart';
import '../../infrastructure/adapters/mock_price_adapter.dart';
import '../../infrastructure/repositories/crypto_repository_impl.dart';
import '../../infrastructure/streaming/binance_streaming_service.dart';
import '../../presentation/bloc/crypto/crypto_bloc.dart';
import '../utils/crypto_preferences.dart';

/// Configuración de inyección de dependencias
/// Implementa arquitectura hexagonal con Ports y Adapters
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static GetIt get instance => _getIt;

  /// Configura todas las dependencias
  static Future<void> setup({String? coinGeckoApiKey}) async {
    // Obtener cryptos seleccionadas por el usuario
    final selectedCryptos = await CryptoPreferences.getSelectedCryptos();
    
    _getIt
      // Core
      ..registerLazySingleton<Logger>(Logger.new)

      // Constants - ahora dinámico basado en preferencias del usuario
      ..registerLazySingleton<List<String>>(
        () => selectedCryptos,
      )

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

      // --- Repositories ---
      ..registerLazySingleton<CryptoRepository>(
        () => CryptoRepositoryImpl(
          priceDataPort: _getIt<PriceDataPort>(),
          logoEnrichmentAdapter: _getIt<LogoEnrichmentAdapter>(),
          calculator: _getIt<TradingCalculator>(),
          monitoredSymbols: _getIt<List<String>>(),
        ),
      )

      // --- Use Cases ---
      ..registerLazySingleton<GetCryptoDataUseCase>(
        () => GetCryptoDataUseCase(_getIt<CryptoRepository>()),
      )

      ..registerLazySingleton<GetAlertsUseCase>(
        () => GetAlertsUseCase(_getIt<CryptoRepository>()),
      )

      // --- BLoCs ---
      ..registerFactory<CryptoBloc>(
        () => CryptoBloc(
          getCryptoDataUseCase: _getIt<GetCryptoDataUseCase>(),
          getAlertsUseCase: _getIt<GetAlertsUseCase>(),
          streamingDataPort: _getIt<StreamingDataPort>(),
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
