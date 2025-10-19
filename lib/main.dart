import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'src/core/config/firebase_config.dart';
import 'src/core/di/service_locator.dart';
import 'src/core/utils/logger.dart';
import 'src/infrastructure/services/firebase_message_handler.dart';
import 'src/infrastructure/services/notification_navigation_handler.dart';
import 'src/infrastructure/services/notification_service.dart';
import 'src/presentation/bloc/alerts/alerts_bloc.dart';
import 'src/presentation/bloc/alerts/alerts_event.dart';
import 'src/presentation/bloc/crypto/crypto_bloc.dart';
import 'src/presentation/bloc/crypto/crypto_event.dart';
import 'src/presentation/managers/theme_manager.dart';
import 'src/presentation/pages/spot_main_page.dart';
import 'src/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with correct options
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Configure dependency injection
  await ServiceLocator.setup();

  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.loadThemePreference();

  // Initialize notification service
  await NotificationService.initialize();

  // Enviar notificación de prueba después de 3 segundos para probar
  Future.delayed(const Duration(seconds: 3), () async {
    await _testNotificationSystem();
  });

  runApp(SpotTradingApp(themeManager: themeManager));
}

/// Sistema completo de prueba de notificaciones
Future<void> _testNotificationSystem() async {
  try {
    AppLogger.notification('🧪 INICIANDO PRUEBA COMPLETA DEL SISTEMA DE NOTIFICACIONES');

    final token = NotificationService.fcmToken;

    if (token != null) {
      AppLogger.notification('🔑 TOKEN FCM PARA PRUEBA: $token');

      // Mostrar información del dispositivo
      final deviceInfo = await NotificationService.getDeviceInfo();
      AppLogger.notification('📱 INFO DISPOSITIVO: $deviceInfo');

      // Verificar permisos
      final permissionsGranted = await NotificationService.areNotificationsEnabled();
      AppLogger.notification('🔐 PERMISOS CONCEDIDOS: $permissionsGranted');

      // Simular notificación local para prueba
      _simulateLocalNotification();
      AppLogger.notification('✅ Notificación simulada localmente');

      // Simular recepción de mensaje FCM en primer plano
      _simulateFCMMessage();

      // Intentar enviar al backend (puede fallar si no está corriendo)
      try {
        await NotificationService.sendTestNotification(
          symbol: 'BTC',
          dropPercent: -5,
        );
        AppLogger.notification('✅ Notificación de prueba enviada al backend');
      } catch (backendError) {
        AppLogger.notification('⚠️ Backend no disponible: $backendError');
        AppLogger.notification('📱 Pero la notificación local y la simulación FCM funcionan');
      }

      AppLogger.notification('🎉 PRUEBA DE NOTIFICACIONES COMPLETADA');
    } else {
      AppLogger.notification('❌ No hay token FCM disponible - revisa la configuración de Firebase');
    }
  } catch (e) {
    AppLogger.error('❌ Error en prueba de notificaciones: $e');
  }
}

/// Simula una notificación FCM completa para prueba
void _simulateFCMMessage() {
  AppLogger.notification('📨 SIMULANDO MENSAJE FCM RECIBIDO...');

  final simulatedMessage = {
    'messageId': 'sim-123456789',
    'notification': {
      'title': '🚨 ALERTA BTC - OPORTUNIDAD DE COMPRA',
      'body': 'Bitcoin cayó 3.2% - IA recomienda BUY con 85% confianza',
    },
    'data': {
      'type': 'trading_alert',
      'symbol': 'BTC',
      'currentPrice': r'$43,500',
      'priceChange': '-3.2',
      'analysis': jsonEncode({
        'recommendation': 'BUY',
        'confidence': 85,
        'reasoning': 'Caída técnica saludable con oportunidad de compra',
        'aiEngine': 'deepseek',
        'newsContext': [
          'Bitcoin cae 5% en corrección técnica',
          'Analistas ven oportunidad de acumulación',
          r'Soporte técnico en $42,000'
        ]
      })
    }
  };

  // Procesar el mensaje simulado como si viniera de Firebase
  final remoteMessage = RemoteMessage.fromMap(simulatedMessage);

  // Llamar al handler directamente para simular recepción
  // Importamos el handler privado usando un método público o creamos uno nuevo
  AppLogger.notification('📊 PROCESANDO MENSAJE SIMULADO...');
  _processSimulatedMessage(remoteMessage);
}

/// Procesa un mensaje simulado (similar al handler real)
void _processSimulatedMessage(RemoteMessage message) {
  AppLogger.notification('📨 ¡MENSAJE SIMULADO RECIBIDO EN PRIMER PLANO!');
  AppLogger.notification('📋 Message ID: ${message.messageId}');
  AppLogger.notification('📝 Título: ${message.notification?.title}');
  AppLogger.notification('📄 Cuerpo: ${message.notification?.body}');
  AppLogger.notification('📊 Datos: ${message.data}');

  final data = message.data;

  // Procesar alertas de trading con análisis IA
  if (data['type'] == 'trading_alert' || data['type'] == 'price_alert') {
    final symbol = data['symbol'];
    final currentPrice = data['currentPrice'];
    final priceChange = data['priceChange'];

    AppLogger.notification('🚨 ALERTA DE TRADING RECIBIDA PARA $symbol');
    AppLogger.notification('💰 Precio actual: $currentPrice');
    AppLogger.notification('📉 Cambio: $priceChange%');

    // Procesar análisis IA si está disponible
    if (data.containsKey('analysis')) {
      try {
        final analysisData = data['analysis'];
        final analysis = analysisData is String
            ? jsonDecode(analysisData)
            : analysisData;

        if (analysis is Map<String, dynamic>) {
          _logSimulatedAIAnalysis(analysis, symbol.toString());
        }
      } catch (e) {
        AppLogger.error('Error al parsear análisis IA simulado: $e');
      }
    }
  }
}

/// Registra el análisis IA simulado en los logs
void _logSimulatedAIAnalysis(Map<String, dynamic> analysis, String symbol) {
  final recommendation = analysis['recommendation'] ?? 'UNKNOWN';
  final confidence = analysis['confidence'] ?? 0;
  final reasoning = analysis['reasoning'] ?? 'Sin razonamiento disponible';
  final aiEngine = analysis['aiEngine'] ?? 'unknown';
  final newsContext = analysis['newsContext'];

  AppLogger.notification('🤖 ANÁLISIS IA SIMULADO PARA $symbol:');
  AppLogger.notification('   📊 Recomendación: $recommendation');
  AppLogger.notification('   🎯 Confianza: $confidence%');
  AppLogger.notification('   🧠 Motor IA: $aiEngine');
  AppLogger.notification('   💭 Razonamiento: $reasoning');

  if (newsContext != null && newsContext is List && newsContext.isNotEmpty) {
    AppLogger.notification('   📰 Contexto de noticias:');
    for (final news in newsContext) {
      AppLogger.notification('      • $news');
    }
  }
}

/// Simula una notificación local para prueba
void _simulateLocalNotification() {
  AppLogger.info('=== SIMULACIÓN DE NOTIFICACIÓN RECIBIDA ===');
  AppLogger.info('Simbolo: BTC');
  AppLogger.info(r'Precio actual: $43,500');
  AppLogger.info('Cambio: -3.2%');
  AppLogger.info('');
  AppLogger.info('ANÁLISIS IA:');
  AppLogger.info('   Recomendación: BUY');
  AppLogger.info('   Confianza: 85%');
  AppLogger.info('   Motor IA: deepseek');
  AppLogger.info('   Razonamiento: Caída técnica saludable con oportunidad de compra');
  AppLogger.info('   Contexto de noticias:');
  AppLogger.info('      • Bitcoin cae 5% en corrección técnica');
  AppLogger.info('      • Analistas ven oportunidad de acumulación');
  AppLogger.info(r'      • Soporte técnico en $42,000');
  AppLogger.info('');
  AppLogger.info('NOTIFICACIÓN PUSH RECIBIDA (simulada)');
  AppLogger.info('   Titulo: ALERTA BTC - OPORTUNIDAD DE COMPRA');
  AppLogger.info('   Cuerpo: Bitcoin cayó 3.2% - IA recomienda BUY con 85% confianza');
}

class SpotTradingApp extends StatelessWidget {

  const SpotTradingApp({
    super.key,
    required this.themeManager,
  });
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
