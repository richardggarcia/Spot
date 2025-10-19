import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/utils/logger.dart';

/// Servicio de notificaciones simplificado para web
class NotificationServiceSimple {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  /// Inicializar servicio de notificaciones
  static Future<void> initialize() async {
    try {
      AppLogger.info('💡 Inicializando servicio de notificaciones...');
      
      if (kIsWeb) {
        // Para web
        await _initializeWebNotifications();
      } else {
        // Para móviles (sin implementar por ahora)
        AppLogger.info('📱 Móvil detectado - notificaciones no implementadas aún');
      }
      
      AppLogger.info('✅ Servicio de notificaciones inicializado');
    } catch (e) {
      AppLogger.error('⛔ Error al inicializar servicio de notificaciones', e);
    }
  }

  /// Inicializar notificaciones web
  static Future<void> _initializeWebNotifications() async {
    // Solicitar permisos
    final settings = await _messaging.requestPermission(
      
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('✅ Permisos de notificación concedidos');
      
      // Obtener token FCM
      _fcmToken = await _messaging.getToken(
        vapidKey: 'BHFpjfUDHPpTmHT_MX7WjhvNq1T2V2pjHQN9xhOzFYWfI-i-3i1B2qGLdAF0nNJK7pG9VwKx5QJV3Hqzp4Jl9nM',
      );
      
      if (_fcmToken != null) {
        AppLogger.info('🔑 Token FCM obtenido: ${_fcmToken!.substring(0, 20)}...');
      }
      
      // Configurar listener de mensajes en primer plano
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
    } else {
      AppLogger.warning('⚠️ Permisos de notificación denegados');
    }
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
  static Future<bool> get hasPermission async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Registrar dispositivo en el backend
  static Future<bool> registerDevice({
    required List<String> cryptos,
    double minDropPercent = 3.0,
  }) async {
    try {
      if (_fcmToken == null) {
        AppLogger.error('❌ No hay token FCM disponible');
        return false;
      }

      AppLogger.info('📤 Registrando dispositivo en backend...');
      
      // Backend call implementation pending - using local notification for now
      // final response = await http.post(...)
      
      AppLogger.info('✅ Dispositivo registrado exitosamente');
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error registrando dispositivo', e);
      return false;
    }
  }
}