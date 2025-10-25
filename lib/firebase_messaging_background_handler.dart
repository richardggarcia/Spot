import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'src/core/utils/logger.dart';

/// Handler para mensajes de Firebase Messaging cuando la app está en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final firebaseOptions = DefaultFirebaseOptions.maybeCurrentPlatform();

  try {
    if (firebaseOptions != null) {
      await Firebase.initializeApp(options: firebaseOptions);
    } else {
      await Firebase.initializeApp();
    }
  } catch (error, stackTrace) {
    AppLogger.error(
      '❌ No se pudo inicializar Firebase en background',
      error,
      stackTrace,
    );
    return;
  }

  AppLogger.info(
    '📥 Push recibido en background (iOS/Android): ${message.messageId}',
    message.data,
  );

  AppLogger.debug('Payload background: ${message.data}');
}
