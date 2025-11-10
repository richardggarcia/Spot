import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../infrastructure/services/user_preferences_remote_service.dart';
import '../../core/utils/logger.dart';

/// Gestor de posiciones para tarjetas arrastrables
class CardPositionManager {
  static const String _positionsKey = 'card_positions';
  static UserPreferencesRemoteService? _remoteService;

  /// Configura el servicio remoto para sincronización con backend
  static void configureRemoteService(UserPreferencesRemoteService service) {
    _remoteService = service;
  }

  /// Guarda la posición de una tarjeta específica
  static Future<void> savePosition(String cardId, Offset position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final posMap = json.decode(positions) as Map<String, dynamic>;
      posMap[cardId] = {'x': position.dx, 'y': position.dy};
      await prefs.setString(_positionsKey, json.encode(posMap));
    } catch (e) {
      // Error saving position handled silently
    }
  }

  /// Obtiene la posición guardada de una tarjeta específica
  static Future<Offset?> getPosition(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final posMap = json.decode(positions) as Map<String, dynamic>;

      if (posMap.containsKey(cardId)) {
        final pos = posMap[cardId] as Map<String, dynamic>;
        return Offset(pos['x'] as double? ?? 0.0, pos['y'] as double? ?? 0.0);
      }
      return null;
    } catch (e) {
      // Error getting position handled silently
      return null;
    }
  }

  /// Guarda todas las posiciones de las tarjetas
  static Future<void> saveAllPositions(Map<String, Offset> positions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final posMap = <String, dynamic>{};

      positions.forEach((cardId, position) {
        posMap[cardId] = {'x': position.dx, 'y': position.dy};
      });

      await prefs.setString(_positionsKey, json.encode(posMap));
    } catch (e) {
      // Error saving all positions handled silently
    }
  }

  /// Obtiene todas las posiciones guardadas
  static Future<Map<String, Offset>> getAllPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final posMap = json.decode(positions) as Map<String, dynamic>;
      final result = <String, Offset>{};

      posMap.forEach((cardId, pos) {
        final position = pos as Map<String, dynamic>;
        result[cardId] = Offset(
          position['x'] as double? ?? 0.0,
          position['y'] as double? ?? 0.0,
        );
      });

      return result;
    } catch (e) {
      // Error getting all positions handled silently
      return {};
    }
  }

  /// Elimina la posición de una tarjeta específica
  static Future<void> removePosition(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final posMap = json.decode(positions) as Map<String, dynamic>
        ..remove(cardId);
      await prefs.setString(_positionsKey, json.encode(posMap));
    } catch (e) {
      // Error removing position handled silently
    }
  }

  /// Limpia todas las posiciones guardadas
  static Future<void> clearAllPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_positionsKey);
    } catch (e) {
      // Error clearing all positions handled silently
    }
  }

  /// Verifica si una tarjeta tiene posición guardada
  static Future<bool> hasPosition(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final posMap = json.decode(positions) as Map<String, dynamic>;
      return posMap.containsKey(cardId);
    } catch (e) {
      // Error checking position handled silently
      return false;
    }
  }

  /// Guarda el orden de las tarjetas (para listas reordenables)
  /// Guarda tanto localmente como en el backend
  Future<void> saveCardOrder(List<String> orderedSymbols) async {
    try {
      // Guardar localmente primero (siempre funciona)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('card_order', json.encode(orderedSymbols));
      AppLogger.info('Orden de tarjetas guardado localmente');

      // Intentar guardar en backend si está configurado
      if (_remoteService != null) {
        // Convertir lista a mapa con índices
        final orderMap = <String, int>{};
        for (var i = 0; i < orderedSymbols.length; i++) {
          orderMap[orderedSymbols[i]] = i;
        }
        await _remoteService!.saveCardOrder(orderMap);
        AppLogger.info('Orden de tarjetas sincronizado con backend');
      }
    } catch (e) {
      AppLogger.error('Error guardando orden de tarjetas: $e');
    }
  }

  /// Obtiene el orden guardado de las tarjetas
  /// Intenta cargar del backend primero, si falla usa SharedPreferences
  Future<List<String>> getCardOrder() async {
    try {
      // Intentar cargar del backend si está configurado
      if (_remoteService != null) {
        try {
          final remoteOrder = await _remoteService!.loadCardOrder();
          if (remoteOrder != null && remoteOrder.isNotEmpty) {
            // Convertir el mapa de orden a lista ordenada
            final sortedEntries = remoteOrder.entries.toList()
              ..sort((a, b) => a.value.compareTo(b.value));
            final orderedSymbols = sortedEntries.map((e) => e.key).toList();

            // Guardar en SharedPreferences para cache local
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('card_order', json.encode(orderedSymbols));
            AppLogger.info('Orden de tarjetas cargado desde backend: ${orderedSymbols.length}');
            return orderedSymbols;
          }
        } catch (e) {
          AppLogger.warning('Error cargando orden desde backend: $e');
        }
      }

      // Si no se pudo cargar del backend, usar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString('card_order');
      if (orderJson == null) {
        AppLogger.info('No hay orden de tarjetas guardado');
        return [];
      }
      final decoded = json.decode(orderJson) as List<dynamic>;
      AppLogger.info('Orden de tarjetas cargado desde SharedPreferences');
      return decoded.cast<String>();
    } catch (e) {
      AppLogger.error('Error obteniendo orden de tarjetas: $e');
      return [];
    }
  }

  /// Limpia el orden guardado de las tarjetas
  Future<void> clearCardOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('card_order');
    } catch (e) {
      // Error clearing card order handled silently
    }
  }
}
