import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../../core/errors/app_exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/ports/trade_journal_port.dart';

class TradeJournalRemoteService implements TradeJournalPort {
  factory TradeJournalRemoteService({
    Dio? dio,
    String? baseUrl,
    String? apiKey,
  }) {
    // Use provided baseUrl or default to public endpoint
    final resolvedBaseUrl = baseUrl ?? 'https://spot.bitsdeve.com';
    final resolvedApiKey = _resolveEffectiveApiKey(apiKey);

    final client =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: resolvedBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (resolvedApiKey.isNotEmpty) 'X-API-Key': resolvedApiKey,
              if (resolvedApiKey.isNotEmpty)
                'Authorization': 'Bearer $resolvedApiKey',
            },
          ),
        );

    if (resolvedApiKey.isEmpty) {
      AppLogger.warning(
        'Journal API key is not configured; las llamadas remotas pueden fallar con 401.',
      );
    }

    return TradeJournalRemoteService._(client);
  }

  TradeJournalRemoteService._(this._dio);

  static String _resolveEffectiveApiKey(String? override) {
    const envKey = String.fromEnvironment('SPOT_JOURNAL_API_KEY');
    return (override ?? envKey).trim();
  }

  final Dio _dio;

  @override
  Future<List<Map<String, dynamic>>> fetchEntries({
    String? userId,
    String? symbol,
    String? order,
    int? limit,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/journal',
        queryParameters: <String, dynamic>{
          if (userId != null) 'userId': userId,
          if (symbol != null) 'symbol': symbol,
          if (order != null) 'order': order,
          if (limit != null) 'limit': limit,
        },
      );

      final data = response.data?['entries'];
      if (data is List) {
        final entries = data.whereType<Map<String, dynamic>>().toList(growable: false);

        // Filtrar preferencias de usuario (no son trades reales)
        return entries.where((entry) {
          final entrySymbol = entry['symbol']?.toString() ?? '';
          final entryTags = entry['tags'] as List<dynamic>?;

          // Excluir si:
          // 1. El símbolo empieza con USER_PREFERENCES_ (preferencias del sistema)
          // 2. Los tags contienen 'preferences' (marcado como preferencia)
          if (entrySymbol.startsWith('USER_PREFERENCES_')) {
            return false;
          }

          if (entryTags != null && entryTags.any((tag) => tag.toString() == 'preferences')) {
            return false;
          }

          return true;
        }).toList(growable: false);
      }

      return const [];
    } on DioException catch (error) {
      AppLogger.error('Error fetching journal entries', error);
      throw NetworkException(
        'No se pudieron obtener las anotaciones',
        code: error.response?.statusCode?.toString(),
        originalError: error,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unexpected error fetching journal entries',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createEntry(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/journal',
        data: payload,
      );

      final entry = response.data?['entry'];
      if (entry is Map<String, dynamic>) {
        return entry;
      }

      throw const ApiException('Respuesta inválida al crear anotación');
    } on DioException catch (error) {
      AppLogger.error('Error creating journal entry', error);
      final status = error.response?.statusCode;
      final message = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['message'] ?? error.message)?.toString()
          : error.message;

      throw NetworkException(
        message ?? 'No se pudo crear la anotación',
        code: status?.toString(),
        originalError: error,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> updateEntry(
    String id,
    Map<String, dynamic> payload, {
    String? userId,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/journal/$id',
        queryParameters: <String, dynamic>{
          if (userId != null) 'userId': userId,
        },
        data: payload,
      );

      final entry = response.data?['entry'];
      if (entry is Map<String, dynamic>) {
        return entry;
      }

      return null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      AppLogger.error('Error updating journal entry', error);
      throw NetworkException(
        'No se pudo actualizar la anotación',
        code: error.response?.statusCode?.toString(),
        originalError: error,
      );
    }
  }

  @override
  Future<bool> deleteEntry(String id, {String? userId}) async {
    try {
      await _dio.delete<void>(
        '/journal/$id',
        queryParameters: <String, dynamic>{
          if (userId != null) 'userId': userId,
        },
      );
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        if (kDebugMode) {
          AppLogger.warning('Intento de eliminar anotación inexistente: $id');
        }
        return false;
      }
      AppLogger.error('Error deleting journal entry', error);
      throw NetworkException(
        'No se pudo eliminar la anotación',
        code: error.response?.statusCode?.toString(),
        originalError: error,
      );
    }
  }
}
