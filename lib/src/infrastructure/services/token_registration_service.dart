import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// Servicio responsable de registrar el token de notificaciones web ante el servidor.
class TokenRegistrationService {
  TokenRegistrationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Registra el token de Firebase en el backend para suscribirlo al topic adecuado.
  Future<void> registerWebDeviceToken(String token) async {
    final uri = Uri.parse('${AppConstants.spotAlertsServerBaseUrl}/webpush/register');

    try {
      AppLogger.info('📡 Registrando token web push con el backend...');

      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        AppLogger.info('✅ Token web push registrado correctamente');
      } else {
        AppLogger.warning(
          '⚠️ Falló el registro del token web push (status: ${response.statusCode}): ${response.body}',
        );
      }
    } catch (error) {
      AppLogger.error('❌ Error registrando token web push', error);
      rethrow;
    }
  }
}
