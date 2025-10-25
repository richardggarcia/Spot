import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';
import 'backend_notification_service.dart';
import 'notification_navigation_handler.dart';

/// Servicio para gestionar las notificaciones push en Android/iOS.
class MobilePushNotificationService {
  MobilePushNotificationService._();

  static final MobilePushNotificationService instance =
      MobilePushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final BackendNotificationService _backendService =
      BackendNotificationService();

  static const _prefsKeyLastToken = 'spot_last_registered_fcm_token';
  static const _prefsKeyLastPlatform = 'spot_last_registered_fcm_platform';
  RemoteMessage? _pendingInitialMessage;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (kIsWeb) {
      return;
    }

    if (!(Platform.isIOS || Platform.isAndroid)) {
      return;
    }

    AppLogger.info('📲 Inicializando notificaciones push móviles...');

    if (Firebase.apps.isEmpty) {
      AppLogger.warning(
        '⚠️ Firebase no está inicializado; se omiten notificaciones push móviles.',
      );
      return;
    }

    await _messaging.setAutoInitEnabled(true);

    // Mostrar notificaciones incluso con la app abierta (iOS 10+)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final status = (await _messaging.requestPermission()).authorizationStatus;

    AppLogger.info('📲 Estado permisos push: $status');

    if (status == AuthorizationStatus.denied ||
        status == AuthorizationStatus.notDetermined) {
      AppLogger.warning('❌ Permisos de notificaciones denegados');
      return;
    }

    // Obtener token inicial
    final token = await _messaging.getToken();
    if (token != null && token.trim().isNotEmpty) {
      await _registerToken(token);
    } else {
      AppLogger.warning('⚠️ No se pudo obtener token FCM inicial');
    }

    // Registrar listeners
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _pendingInitialMessage = await _messaging.getInitialMessage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_flushPendingInitialMessage());
    });

    _messaging.onTokenRefresh.listen((String refreshedToken) async {
      AppLogger.info('♻️ Token FCM refrescado (mobile)');
      await _registerToken(refreshedToken);
    });

    _initialized = true;
  }

  Future<void> _flushPendingInitialMessage() async {
    if (_pendingInitialMessage == null) {
      return;
    }

    await _handleNotificationTap(_pendingInitialMessage!);
    _pendingInitialMessage = null;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    AppLogger.notification(
      'Push recibido en foreground: '
      '${notification?.title ?? '(sin título)'}',
      message.data,
    );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    if (message.data.isEmpty) {
      AppLogger.warning('Tap en notificación sin data asociada.');
      return;
    }

    AppLogger.info(
      '🖱️ Tap en notificación (mobile): ${message.data}',
    );

    await NotificationNavigationHandler()
        .handleNotificationTap(message.data);
  }

  Future<void> _registerToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final lastToken = prefs.getString(_prefsKeyLastToken);
    final lastPlatform = prefs.getString(_prefsKeyLastPlatform);
    final platform = Platform.isIOS ? 'ios' : 'android';

    if (lastToken == token && lastPlatform == platform) {
      AppLogger.info('Token FCM ya registrado previamente. Se omite envío.');
      return;
    }

    try {
      AppLogger.info('📡 Registrando token FCM en backend...');
      await _backendService.registerDevice(
        fcmToken: token,
        platform: platform,
      );

      await prefs.setString(_prefsKeyLastToken, token);
      await prefs.setString(_prefsKeyLastPlatform, platform);
      AppLogger.info('✅ Token FCM registrado y almacenado localmente');
    } catch (error) {
      AppLogger.error('❌ Falló el registro del token FCM', error);
    }
  }
}
