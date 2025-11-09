import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/core/di/service_locator.dart';
import 'src/core/utils/logger.dart';
import 'src/infrastructure/services/notification_navigation_handler.dart';
import 'src/infrastructure/services/web_push_notification_service.dart';
import 'src/presentation/bloc/alerts/alerts_bloc.dart';
import 'src/presentation/bloc/alerts/alerts_event.dart';
import 'src/presentation/bloc/crypto/crypto_bloc.dart';
import 'src/presentation/bloc/crypto/crypto_event.dart';
import 'src/presentation/bloc/journal/journal_bloc.dart';
import 'src/presentation/bloc/journal/journal_event.dart';
import 'src/presentation/managers/theme_manager.dart';
import 'src/presentation/pages/spot_main_page.dart';
import 'src/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  AppLogger.info('🚀 Iniciando SPOT - Trading de Price Action');

  var firebaseInitialized = false;

  FirebaseOptions? firebaseOptions;
  if (kIsWeb) {
    firebaseOptions = DefaultFirebaseOptions.web;
  } else {
    firebaseOptions = DefaultFirebaseOptions.maybeCurrentPlatform();
  }

  try {
    if (firebaseOptions != null) {
      await Firebase.initializeApp(options: firebaseOptions);
      firebaseInitialized = true;
      AppLogger.info('🔥 Firebase inicializado con opciones específicas');
    } else if (!kIsWeb) {
      await Firebase.initializeApp();
      firebaseInitialized = true;
      AppLogger.info(
        '🔥 Firebase inicializado usando configuración nativa (GoogleService-Info.plist)',
      );
    } else {
      AppLogger.warning(
        '⚠️ Firebase no tiene configuración para esta plataforma; '
        'se continúa sin servicios de notificaciones.',
      );
    }
  } catch (error, stackTrace) {
    AppLogger.error('❌ Error inicializando Firebase', error, stackTrace);
  }

  if (firebaseInitialized) {
    if (kIsWeb) {
      await WebPushNotificationService.instance.initialize();
    } else {
      // Temporarily disabled for iOS (requires paid developer account for APNS)
      AppLogger.warning(
        '⚠️ Notificaciones móviles temporalmente deshabilitadas (requiere cuenta de desarrollador paga de iOS para APNS)',
      );
      // TODO(team): Re-enable when iOS developer account is configured
      // FirebaseMessaging.onBackgroundMessage(
      //   firebaseMessagingBackgroundHandler,
      // );
      // await MobilePushNotificationService.instance.initialize();
    }
  } else {
    AppLogger.warning(
      '⚠️ Firebase no quedó inicializado; las notificaciones push estarán deshabilitadas.',
    );
  }

  // Configure dependency injection
  await ServiceLocator.setup();

  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.loadThemePreference();

  AppLogger.info('✅ Inicialización completada - Lanzando app');

  runApp(SpotTradingApp(themeManager: themeManager));
}

class SpotTradingApp extends StatelessWidget {
  const SpotTradingApp({super.key, required this.themeManager});
  final ThemeManager themeManager;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      // Theme management
      ChangeNotifierProvider.value(value: themeManager),

      // BLoC providers
      BlocProvider(
        create: (context) =>
            ServiceLocator.get<CryptoBloc>()
              ..add(const GetAllCryptosWithMetrics()),
      ),
      BlocProvider(
        create: (context) =>
            AlertsBloc(getAlertsUseCase: ServiceLocator.get())
              ..add(const GetAllAlerts()),
      ),
      BlocProvider(
        create: (context) =>
            ServiceLocator.get<JournalBloc>()
              ..add(const LoadJournalNotes(userId: 'richard')),
      ),
    ],
    child: Consumer<ThemeManager>(
      builder: (context, themeManager, child) => MaterialApp(
        navigatorKey: NotificationNavigationHandler().navigatorKey,
        title: 'Buy The Dip',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeManager.themeMode,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('es', ''), // Spanish
        ],
        home: const SpotMainPage(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
