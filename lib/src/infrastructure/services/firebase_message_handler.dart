import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/utils/logger.dart';

/// Handler de mensajes Firebase en background
/// DEBE ser una función top-level (fuera de clases)
/// Se ejecuta cuando la app está cerrada o en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Mensaje recibido en background: ${message.messageId}');

  // Aquí puedes procesar el mensaje silenciosamente
  // NO se debe mostrar UI aquí (la notificación se muestra automáticamente)

  final data = message.data;
  if (data['type'] == 'price_alert') {
    final symbol = data['symbol'];
    final dropPercent = data['dropPercent'];
    AppLogger.info('Alerta de precio para $symbol: $dropPercent%');
  }
}
