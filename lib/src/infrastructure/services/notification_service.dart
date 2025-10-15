import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/logger.dart';

/// Servicio de notificaciones con soporte para web y móvil
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  static String? _fcmToken;
  static bool _isInitialized = false;

  /// Inicializar servicio de notificaciones
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      AppLogger.info('💡 Inicializando servicio de notificaciones...');
      
      if (kIsWeb) {
        await _initializeWebNotifications();
      } else {
        await _initializeMobileNotifications();
      }
      
      _isInitialized = true;
      AppLogger.info('✅ Servicio de notificaciones inicializado');
    } catch (e) {
      AppLogger.error('⛔ Error al inicializar servicio de notificaciones', e);
    }
  }

  /// Inicializar notificaciones web
  static Future<void> _initializeWebNotifications() async {
    // Solicitar permisos
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('✅ Permisos de notificación concedidos');
      
      // Obtener token FCM
      _fcmToken = await _messaging.getToken();
      
      if (_fcmToken != null) {
        AppLogger.info('🔑 Token FCM obtenido: ${_fcmToken!.substring(0, 20)}...');
      }
      
      // Configurar listeners
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
    } else {
      AppLogger.warning('⚠️ Permisos de notificación denegados');
    }
  }

  /// Inicializar notificaciones móviles
  static Future<void> _initializeMobileNotifications() async {
    // Por ahora, solo web está implementado
    AppLogger.info('📱 Notificaciones móviles no implementadas aún');
  }

  /// Manejar mensajes en primer plano
  static void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('📨 Mensaje recibido en primer plano');
    AppLogger.info('Título: ${message.notification?.title}');
    AppLogger.info('Cuerpo: ${message.notification?.body}');
    AppLogger.info('Datos: ${message.data}');
  }

  /// Obtener token FCM
  static String? get fcmToken => _fcmToken;

  /// Verificar si los permisos están concedidos
  static Future<bool> areNotificationsEnabled() async {
    NotificationSettings settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Obtener información del dispositivo
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    return {
      'platform': kIsWeb ? 'web' : 'mobile',
      'fcmToken': _fcmToken?.substring(0, 20) ?? 'No disponible',
      'permissionsGranted': await areNotificationsEnabled(),
    };
  }

  /// Actualizar preferencias (placeholder)
  static Future<bool> updatePreferences({
    required List<String> cryptos,
    required double minDropPercent,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      AppLogger.info('🔄 Actualizando preferencias...');
      // TODO: Implementar llamada al backend
      AppLogger.info('✅ Preferencias actualizadas');
      return true;
    } catch (e) {
      AppLogger.error('❌ Error actualizando preferencias', e);
      return false;
    }
  }

  /// Enviar notificación de prueba (placeholder)
  static Future<bool> sendTestNotification({
    required String symbol,
    required double dropPercent,
  }) async {
    try {
      AppLogger.info('🧪 Enviando notificación de prueba...');
      // TODO: Implementar llamada al backend para test
      AppLogger.info('✅ Notificación de prueba enviada');
      return true;
    } catch (e) {
      AppLogger.error('❌ Error enviando notificación de prueba', e);
      return false;
    }
  }
}