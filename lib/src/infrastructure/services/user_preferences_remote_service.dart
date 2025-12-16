import 'dart:convert';
import 'package:dio/dio.dart';

import '../../core/utils/logger.dart';

/// Servicio para sincronizar preferencias de usuario con el backend
class UserPreferencesRemoteService {
  UserPreferencesRemoteService({
    required Dio dio,
    required String userId,
  })  : _dio = dio,
        _userId = userId;

  final Dio _dio;
  final String _userId;

  /// Guarda las preferencias de criptos seleccionadas en el backend
  Future<bool> saveSelectedCryptos(List<String> symbols) async {
    try {
      final payload = {
        'symbol': 'USER_PREFERENCES_CRYPTOS',
        'side': 'preference',
        'entryPrice': 0,
        'entryAt': DateTime.now().toIso8601String(),
        'notes': jsonEncode({'selectedCryptos': symbols}),
        'userId': _userId,
        'tags': ['preferences', 'crypto_selection'],
      };

      await _dio.post<Map<String, dynamic>>(
        '/journal',
        data: payload,
      );

      AppLogger.info('Preferencias de cryptos guardadas en backend');
      return true;
    } catch (error) {
      AppLogger.warning('No se pudieron guardar preferencias en backend: $error');
      return false;
    }
  }

  /// Carga las preferencias de criptos seleccionadas desde el backend
  Future<List<String>?> loadSelectedCryptos() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/journal',
        queryParameters: {
          'userId': _userId,
          'symbol': 'USER_PREFERENCES_CRYPTOS',
          'limit': 1,
        },
      );

      final data = response.data?['entries'];
      if (data is List && data.isNotEmpty) {
        final entry = data.first as Map<String, dynamic>;
        final notesStr = entry['notes'] as String?;

        if (notesStr != null && notesStr.isNotEmpty) {
          final preferences = jsonDecode(notesStr) as Map<String, dynamic>;
          final cryptos = preferences['selectedCryptos'] as List<dynamic>?;

          if (cryptos != null) {
            AppLogger.info('Preferencias de cryptos cargadas desde backend');
            return cryptos.map((e) => e.toString()).toList();
          }
        }
      }

      return null;
    } catch (error) {
      AppLogger.warning('No se pudieron cargar preferencias desde backend: $error');
      return null;
    }
  }

  /// Guarda el orden de las tarjetas en el backend
  Future<bool> saveCardOrder(Map<String, int> order) async {
    try {
      final payload = {
        'symbol': 'USER_PREFERENCES_CARD_ORDER',
        'side': 'preference',
        'entryPrice': 0,
        'entryAt': DateTime.now().toIso8601String(),
        'notes': jsonEncode({'cardOrder': order}),
        'userId': _userId,
        'tags': ['preferences', 'card_order'],
      };

      await _dio.post<Map<String, dynamic>>(
        '/journal',
        data: payload,
      );

      AppLogger.info('Orden de tarjetas guardado en backend');
      return true;
    } catch (error) {
      AppLogger.warning('No se pudo guardar orden de tarjetas en backend: $error');
      return false;
    }
  }

  /// Carga el orden de las tarjetas desde el backend
  Future<Map<String, int>?> loadCardOrder() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/journal',
        queryParameters: {
          'userId': _userId,
          'symbol': 'USER_PREFERENCES_CARD_ORDER',
          'limit': 1,
        },
      );

      final data = response.data?['entries'];
      if (data is List && data.isNotEmpty) {
        final entry = data.first as Map<String, dynamic>;
        final notesStr = entry['notes'] as String?;

        if (notesStr != null && notesStr.isNotEmpty) {
          final preferences = jsonDecode(notesStr) as Map<String, dynamic>;
          final order = preferences['cardOrder'] as Map<String, dynamic>?;

          if (order != null) {
            AppLogger.info('Orden de tarjetas cargado desde backend');
            return order.map((k, v) => MapEntry(k, v as int));
          }
        }
      }

      return null;
    } catch (error) {
      AppLogger.warning('No se pudo cargar orden de tarjetas desde backend: $error');
      return null;
    }
  }
}
