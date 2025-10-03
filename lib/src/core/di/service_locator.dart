import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../domain/ports/price_data_port.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/use_cases/get_crypto_data_usecase.dart';
import '../../domain/use_cases/get_alerts_usecase.dart';
import '../../domain/services/trading_calculator.dart';
import '../../infrastructure/adapters/binance_price_adapter.dart';
import '../../infrastructure/adapters/coingecko_price_adapter.dart';
import '../../infrastructure/adapters/hybrid_price_adapter.dart';
import '../../infrastructure/repositories/crypto_repository_impl.dart';
import '../constants/app_constants.dart';

/// Configuración de inyección de dependencias
/// Implementa arquitectura hexagonal con Ports y Adapters
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static GetIt get instance => _getIt;

  /// Configura todas las dependencias
  static Future<void> setup({String? coinGeckoApiKey}) async {
    // Core
    _getIt.registerLazySingleton<Logger>(() => Logger());

    // Constants
    _getIt.registerLazySingleton<List<String>>(
      () => AppConstants.monitoredSymbols,
    );

    // Domain Services
    _getIt.registerLazySingleton<TradingCalculator>(() => TradingCalculator());

    // Adapters (Ports implementations)
    // 1. Binance Adapter (Principal - gratis, sin límites)
    _getIt.registerLazySingleton<PriceDataPort>(
      () => HybridPriceAdapter(
        primaryAdapter: BinancePriceAdapter(),
        backupAdapter: CoinGeckoPriceAdapter(
          apiKey: coinGeckoApiKey, // Opcional: API key para más calls
        ),
      ),
      instanceName: 'hybrid',
    );

    // LLM Port (opcional, para veredictos)
    // TODO: Implementar adapter para LLM cuando esté disponible
    // _getIt.registerLazySingleton<LlmAnalysisPort>(() => ...);

    // Repositories
    _getIt.registerLazySingleton<CryptoRepository>(
      () => CryptoRepositoryImpl(
        priceDataPort: _getIt<PriceDataPort>(instanceName: 'hybrid'),
        llmPort: null, // Sin LLM por ahora
        calculator: _getIt<TradingCalculator>(),
        monitoredSymbols: _getIt<List<String>>(),
      ),
    );

    // Use Cases
    _getIt.registerLazySingleton<GetCryptoDataUseCase>(
      () => GetCryptoDataUseCase(_getIt<CryptoRepository>()),
    );

    _getIt.registerLazySingleton<GetAlertsUseCase>(
      () => GetAlertsUseCase(_getIt<CryptoRepository>()),
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
  static T get<T extends Object>() {
    return _getIt<T>();
  }

  /// Verifica si una dependencia está registrada
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}
