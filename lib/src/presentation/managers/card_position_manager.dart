import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestor de posiciones para tarjetas arrastrables
class CardPositionManager {
  static const String _positionsKey = 'card_positions';

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
  Future<void> saveCardOrder(List<String> orderedSymbols) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('card_order', json.encode(orderedSymbols));
    } catch (e) {
      // Error saving card order handled silently
    }
  }

  /// Obtiene el orden guardado de las tarjetas
  Future<List<String>> getCardOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString('card_order');
      if (orderJson == null) return [];
      final decoded = json.decode(orderJson) as List<dynamic>;
      return decoded.cast<String>();
    } catch (e) {
      // Error getting card order handled silently
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
