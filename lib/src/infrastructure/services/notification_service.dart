import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/utils/logger.dart';
import '../../domain/entities/device_registration.dart';
import 'backend_notification_service.dart';

/// Servicio de notificaciones con soporte para web y móvil
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  static String? _fcmToken;
  static bool _isInitialized = false;

  /// Inicializar servicio de notificaciones
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.notification('💡 Inicializando servicio de notificaciones...');
      AppLogger.notification('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

      if (kIsWeb) {
        await _initializeWebNotifications();
      } else {
        await _initializeMobileNotifications();
      }

      _isInitialized = true;
      AppLogger.notification('✅ Servicio de notificaciones inicializado correctamente');
    } catch (e) {
      AppLogger.error('⛔ Error al inicializar servicio de notificaciones', e);
    }
  }

  /// Inicializar notificaciones web
  static Future<void> _initializeWebNotifications() async {
    AppLogger.notification('🔔 Solicitando permisos de notificación web...');

    // Solicitar permisos
    final settings = await _messaging.requestPermission();

    AppLogger.notification('📋 Estado de permisos: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.notification('✅ Permisos de notificación concedidos');

      // Obtener token FCM
      AppLogger.notification('🔑 Obteniendo token FCM...');
      _fcmToken = await _messaging.getToken(
        vapidKey: 'BHFpjfUDHPpTmHT_MX7WjhvNq1T2V2pjHQN9xhOzFYWfI-i-3i1B2qGLdAF0nNJK7pG9VwKx5QJV3Hqzp4Jl9nM',
      );

      if (_fcmToken != null) {
        AppLogger.notification('🔑 TOKEN FCM OBTENIDO: ${_fcmToken!.substring(0, 20)}...');
        AppLogger.notification('🔑 TOKEN COMPLETO PARA PRUEBA: $_fcmToken');

        // Suscribirse al topic de alertas de trading
        AppLogger.notification('📡 Suscribiéndose al topic: spot-trading-alerts');
        await _messaging.subscribeToTopic('spot-trading-alerts');
        AppLogger.notification('✅ Suscrito al topic: spot-trading-alerts');

        // Configurar listeners
        AppLogger.notification('👂 Configurando listeners de mensajes en primer plano...');
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        AppLogger.notification('✅ Listeners configurados correctamente');
      } else {
        AppLogger.error('❌ No se pudo obtener el token FCM');
      }
    } else {
      AppLogger.notification('⚠️ Permisos de notificación denegados: ${settings.authorizationStatus}');
    }
  }

  /// Inicializar notificaciones móviles
  static Future<void> _initializeMobileNotifications() async {
    // Por ahora, solo web está implementado
    AppLogger.info('📱 Notificaciones móviles no implementadas aún');
  }

  /// Manejar mensajes en primer plano
  static void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.notification('📨 ¡MENSAJE RECIBIDO EN PRIMER PLANO!');
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
            _logAIAnalysis(analysis, symbol.toString());
          }
        } catch (e) {
          AppLogger.error('Error al parsear análisis IA: $e');
        }
      }
    }
  }

  /// Registra el análisis IA en los logs
  static void _logAIAnalysis(Map<String, dynamic> analysis, String symbol) {
    final recommendation = analysis['recommendation'] ?? 'UNKNOWN';
    final confidence = analysis['confidence'] ?? 0;
    final reasoning = analysis['reasoning'] ?? 'Sin razonamiento disponible';
    final aiEngine = analysis['aiEngine'] ?? 'unknown';
    final newsContext = analysis['newsContext'];

    AppLogger.notification('🤖 ANÁLISIS IA PARA $symbol:');
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

  /// Obtener token FCM
  static String? get fcmToken => _fcmToken;

  /// Verificar si los permisos están concedidos
  static Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Obtener información del dispositivo
  static Future<Map<String, dynamic>> getDeviceInfo() async => {
      'platform': kIsWeb ? 'web' : 'mobile',
      'fcmToken': _fcmToken?.substring(0, 20) ?? 'No disponible',
      'permissionsGranted': await areNotificationsEnabled(),
    };

  /// Actualizar preferencias usando el backend real
  static Future<bool> updatePreferences({
    required List<String> cryptos,
    required double minDropPercent,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      if (_fcmToken == null) {
        AppLogger.error('❌ No hay token FCM disponible para actualizar preferencias');
        return false;
      }

      AppLogger.info('🔄 Actualizando preferencias en backend...');

      await BackendNotificationService().updatePreferences(
        fcmToken: _fcmToken!,
        cryptos: cryptos,
        minDropPercent: minDropPercent,
        preferences: preferences != null
            ? NotificationPreferences.fromJson(preferences)
            : null,
        enabled: preferences?['enabled'] as bool? ?? true,
      );

      AppLogger.info('✅ Preferencias actualizadas correctamente');
      return true;
    } catch (e) {
      AppLogger.error('❌ Error actualizando preferencias', e);
      return false;
    }
  }

  /// Enviar notificación de prueba usando el backend real
  static Future<bool> sendTestNotification({
    required String symbol,
    required double dropPercent,
  }) async {
    try {
      if (_fcmToken == null) {
        AppLogger.error('❌ No hay token FCM disponible para enviar notificación de prueba');
        return false;
      }

      AppLogger.info('🧪 Enviando notificación de prueba al backend...');

      await BackendNotificationService().sendTestNotification(
        fcmToken: _fcmToken!,
        symbol: symbol,
        dropPercent: dropPercent,
      );

      AppLogger.info('✅ Notificación de prueba enviada correctamente');
      return true;
    } catch (e) {
      AppLogger.error('❌ Error enviando notificación de prueba', e);
      return false;
    }
  }
}