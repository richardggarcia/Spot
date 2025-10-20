import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/device_registration.dart';

/// Servicio para comunicarse con el backend de notificaciones
/// Backend: http://192.168.1.34:8080
class BackendNotificationService {
  factory BackendNotificationService() => _instance;
  BackendNotificationService._internal();
  static final BackendNotificationService _instance =
      BackendNotificationService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.34:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Registra el dispositivo en el backend
  /// POST /api/register-device
  Future<DeviceRegistrationResponse> registerDevice({
    required String fcmToken,
    required String platform,
    List<String>? cryptos,
    double? minDropPercent,
    NotificationPreferences? preferences,
  }) async {
    try {
      AppLogger.info('Registrando dispositivo en backend...');
      AppLogger.info('Platform: $platform');
      AppLogger.info('FCM Token: ${fcmToken.substring(0, 20)}...');

      final registration = DeviceRegistration(
        fcmToken: fcmToken,
        platform: platform,
        cryptos: cryptos ?? _getDefaultCryptos(),
        minDropPercent: minDropPercent ?? 3.0,
        preferences: preferences,
      );

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/register-device',
        data: registration.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = DeviceRegistrationResponse.fromJson(
          response.data!,
        );
        AppLogger.info('Dispositivo registrado exitosamente: ${result.message}');
        return result;
      } else {
        throw ApiException(
          'Error al registrar dispositivo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Error de red al registrar dispositivo', e);
      throw NetworkException(
        'No se pudo conectar con el servidor de notificaciones',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Error inesperado al registrar dispositivo', e);
      rethrow;
    }
  }

  /// Actualiza las preferencias del dispositivo
  /// PUT /api/device/{fcmToken}/preferences
  Future<void> updatePreferences({
    required String fcmToken,
    List<String>? cryptos,
    double? minDropPercent,
    NotificationPreferences? preferences,
    bool? enabled,
  }) async {
    try {
      AppLogger.info('Actualizando preferencias del dispositivo...');

      final data = <String, dynamic>{};
      if (cryptos != null) data['cryptos'] = cryptos;
      if (minDropPercent != null) data['minDropPercent'] = minDropPercent;
      if (preferences != null) data['preferences'] = preferences.toJson();
      if (enabled != null) data['enabled'] = enabled;

      final response = await _dio.put<Map<String, dynamic>>(
        '/api/device/$fcmToken/preferences',
        data: data,
      );

      if (response.statusCode == 200) {
        AppLogger.info('Preferencias actualizadas exitosamente');
      } else {
        throw ApiException(
          'Error al actualizar preferencias',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Error de red al actualizar preferencias', e);
      throw NetworkException(
        'No se pudo conectar con el servidor',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Error inesperado al actualizar preferencias', e);
      rethrow;
    }
  }

  /// Obtiene información del dispositivo registrado
  /// GET /api/device/{fcmToken}
  Future<Map<String, dynamic>?> getDeviceInfo(String fcmToken) async {
    try {
      AppLogger.info('Obteniendo información del dispositivo...');

      final response = await _dio.get<Map<String, dynamic>>('/api/device/$fcmToken');

      if (response.statusCode == 200) {
        AppLogger.info('Información del dispositivo obtenida');
        return response.data;
      } else if (response.statusCode == 404) {
        AppLogger.warning('Dispositivo no encontrado en el backend');
        return null;
      } else {
        throw ApiException(
          'Error al obtener información del dispositivo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      AppLogger.error('Error de red al obtener información del dispositivo', e);
      throw NetworkException(
        'No se pudo conectar con el servidor',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Error inesperado al obtener información del dispositivo', e);
      rethrow;
    }
  }

  /// Desregistra el dispositivo del backend
  /// DELETE /api/device/{fcmToken}
  Future<void> unregisterDevice(String fcmToken) async {
    try {
      AppLogger.info('Desregistrando dispositivo del backend...');

      final response = await _dio.delete<Map<String, dynamic>>('/api/device/$fcmToken');

      if (response.statusCode == 200) {
        AppLogger.info('Dispositivo desregistrado exitosamente');
      } else {
        throw ApiException(
          'Error al desregistrar dispositivo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Error de red al desregistrar dispositivo', e);
      throw NetworkException(
        'No se pudo conectar con el servidor',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Error inesperado al desregistrar dispositivo', e);
      rethrow;
    }
  }

  /// Envía una notificación de prueba
  /// POST /api/test-notification
  Future<void> sendTestNotification({
    required String fcmToken,
    required String symbol,
    double dropPercent = -5.0,
  }) async {
    try {
      AppLogger.info('Enviando notificación de prueba...');

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/test-notification',
        data: {
          'fcmToken': fcmToken,
          'symbol': symbol,
          'dropPercent': dropPercent,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.info('Notificación de prueba enviada exitosamente');
      } else {
        throw ApiException(
          'Error al enviar notificación de prueba',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Error de red al enviar notificación de prueba', e);
      throw NetworkException(
        'No se pudo conectar con el servidor',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Error inesperado al enviar notificación de prueba', e);
      rethrow;
    }
  }

  /// Obtiene la lista por defecto de cryptos a monitorear
  List<String> _getDefaultCryptos() => [
      'BTC',
      'ETH',
      'BNB',
      'SOL',
      'XRP',
      'LINK',
      'LTC',
      'BCH',
      'TON',
      'SUI',
      'MNT',
      'RON',
      'KCS',
      'BGB',
    ];

  /// Obtiene el nombre de la plataforma
  static String getPlatform() {
    if (kIsWeb) {
      return 'web';
    }
    
    try {
      if (Platform.isIOS) {
        return 'ios';
      } else if (Platform.isAndroid) {
        return 'android';
      } else {
        return 'unknown';
      }
    } catch (e) {
      // Fallback para web u otras plataformas
      return 'web';
    }
  }
}
