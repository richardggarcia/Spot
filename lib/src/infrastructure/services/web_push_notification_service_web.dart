import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/firebase_web_config.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/notification_data.dart';
import 'notification_navigation_handler.dart';
import 'token_registration_service.dart';

final FirebaseMessaging _messaging = FirebaseMessaging.instance;
final TokenRegistrationService _tokenRegistrationService =
    TokenRegistrationService();
StreamSubscription<String>? _tokenRefreshSubscription;
html.EventListener? _messageListener;

Future<void> initializeWebPushMessaging() async {
  if (!kIsWeb) {
    return;
  }

  try {
    AppLogger.info('🌐 Inicializando Firebase Messaging para Web...');

    final isSupported = await _messaging.isSupported();
    if (!isSupported) {
      AppLogger.warning(
        '⚠️ El navegador actual no soporta Web Push (se omite inicialización)',
      );
      return;
    }

    final settings = await _messaging.requestPermission();

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      AppLogger.warning('⚠️ Usuario negó permisos de notificaciones web');
      return;
    }

    final vapidKey = FirebaseWebConfig.vapidKey.trim();
    if (vapidKey.isEmpty || vapidKey == 'REPLACE_WITH_WEB_PUSH_CERTIFICATE_KEY') {
      AppLogger.warning(
        '⚠️ VAPID key para web push no configurada. '
        'Actualiza FirebaseWebConfig.vapidKey con la clave pública.',
      );
      return;
    }

    final token = await _messaging.getToken(vapidKey: vapidKey);
    if (token != null) {
      AppLogger.info(
        '🔑 Token web push obtenido: ${token.substring(0, 15)}...',
      );
      await _tokenRegistrationService.registerWebDeviceToken(token);
    } else {
      AppLogger.warning(
        '⚠️ No se pudo obtener token de Firebase Messaging web',
      );
    }
  } catch (error) {
    AppLogger.error(
      '❌ Error inicializando notificaciones web, se continúa sin push',
      error,
    );
    return;
  }

  _listenToForegroundMessages();
  _listenToNotificationClicks();
  _listenToTokenRefresh();
}

Future<void> disposeWebPushMessaging() async {
  await _tokenRefreshSubscription?.cancel();
  _tokenRefreshSubscription = null;

  if (_messageListener != null) {
    html.window.removeEventListener('message', _messageListener);
    _messageListener = null;
  }
}

void _listenToForegroundMessages() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    AppLogger.info(
      '📬 Notificación recibida en foreground (web): '
      'title=${notification?.title}, body=${notification?.body}, data=$data',
    );
  });
}

void _listenToTokenRefresh() {
  _tokenRefreshSubscription?.cancel();
  _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((
    String token,
  ) async {
    AppLogger.info('♻️ Token web push refrescado');
    await _tokenRegistrationService.registerWebDeviceToken(token);
  });
}

void _listenToNotificationClicks() {
  _messageListener ??= (event) {
    if (event is! html.MessageEvent || event.data is! Map) {
      return;
    }

    final data = Map<String, dynamic>.from(event.data as Map);
    if (data['type'] != 'NOTIFICATION_CLICK') {
      return;
    }

    final notificationData = <String, dynamic>{};

    if (data['data'] is Map) {
      notificationData.addAll(Map<String, dynamic>.from(data['data'] as Map));
    }

    if (data['symbol'] is String && notificationData['symbol'] == null) {
      notificationData['symbol'] = data['symbol'] as String;
    }

    notificationData.putIfAbsent(
      'type',
      () => NotificationType.priceAlert.value,
    );

    AppLogger.info('🖱️ Click en notificación web recibido');
    NotificationNavigationHandler().handleNotificationTap(notificationData);
  };

  html.window.addEventListener('message', _messageListener);
}
