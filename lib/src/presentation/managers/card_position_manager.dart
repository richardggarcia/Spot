import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Gestor de posiciones para tarjetas arrastrables
class CardPositionManager {
  static const String _positionsKey = 'card_positions';

  /// Guarda la posición de una tarjeta específica
  static Future<void> savePosition(String cardId, Offset position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final Map<String, dynamic> posMap = json.decode(positions);
      posMap[cardId] = {'x': position.dx, 'y': position.dy};
      await prefs.setString(_positionsKey, json.encode(posMap));
    } catch (e) {
      debugPrint('Error saving position for $cardId: $e');
    }
  }

  /// Obtiene la posición guardada de una tarjeta específica
  static Future<Offset?> getPosition(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final Map<String, dynamic> posMap = json.decode(positions);

      if (posMap.containsKey(cardId)) {
        final pos = posMap[cardId];
        return Offset(pos['x']?.toDouble() ?? 0.0, pos['y']?.toDouble() ?? 0.0);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting position for $cardId: $e');
      return null;
    }
  }

  /// Guarda todas las posiciones de las tarjetas
  static Future<void> saveAllPositions(Map<String, Offset> positions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> posMap = {};

      positions.forEach((cardId, position) {
        posMap[cardId] = {'x': position.dx, 'y': position.dy};
      });

      await prefs.setString(_positionsKey, json.encode(posMap));
    } catch (e) {
      debugPrint('Error saving all positions: $e');
    }
  }

  /// Obtiene todas las posiciones guardadas
  static Future<Map<String, Offset>> getAllPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final Map<String, dynamic> posMap = json.decode(positions);
      final Map<String, Offset> result = {};

      posMap.forEach((cardId, pos) {
        result[cardId] = Offset(
          pos['x']?.toDouble() ?? 0.0,
          pos['y']?.toDouble() ?? 0.0,
        );
      });

      return result;
    } catch (e) {
      debugPrint('Error getting all positions: $e');
      return {};
    }
  }

  /// Elimina la posición de una tarjeta específica
  static Future<void> removePosition(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final Map<String, dynamic> posMap = json.decode(positions);
      posMap.remove(cardId);
      await prefs.setString(_positionsKey, json.encode(posMap));
    } catch (e) {
      debugPrint('Error removing position for $cardId: $e');
    }
  }

  /// Limpia todas las posiciones guardadas
  static Future<void> clearAllPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_positionsKey);
    } catch (e) {
      debugPrint('Error clearing all positions: $e');
    }
  }

  /// Verifica si una tarjeta tiene posición guardada
  static Future<bool> hasPosition(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positions = prefs.getString(_positionsKey) ?? '{}';
      final Map<String, dynamic> posMap = json.decode(positions);
      return posMap.containsKey(cardId);
    } catch (e) {
      debugPrint('Error checking position for $cardId: $e');
      return false;
    }
  }

  /// Guarda el orden de las tarjetas (para listas reordenables)
  Future<void> saveCardOrder(List<String> orderedSymbols) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('card_order', json.encode(orderedSymbols));
    } catch (e) {
      debugPrint('Error saving card order: $e');
    }
  }

  /// Obtiene el orden guardado de las tarjetas
  Future<List<String>> getCardOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString('card_order');
      if (orderJson == null) return [];
      final List<dynamic> decoded = json.decode(orderJson);
      return decoded.cast<String>();
    } catch (e) {
      debugPrint('Error getting card order: $e');
      return [];
    }
  }

  /// Limpia el orden guardado de las tarjetas
  Future<void> clearCardOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('card_order');
    } catch (e) {
      debugPrint('Error clearing card order: $e');
    }
  }
}
