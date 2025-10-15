import 'dart:convert';

/// Tipos de notificaciones soportadas
enum NotificationType {
  priceAlert('price_alert'),
  general('general'),
  unknown('unknown');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String? value) {
    if (value == null) return NotificationType.unknown;

    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.unknown,
    );
  }
}

/// Datos de una notificación
/// Representa la información estructurada que viene en el payload
class NotificationData {
  final NotificationType type;
  final String? symbol;
  final String? cryptoName;
  final double? dropPercent;
  final double? currentPrice;
  final String? message;
  final Map<String, dynamic> rawData;

  const NotificationData({
    required this.type,
    this.symbol,
    this.cryptoName,
    this.dropPercent,
    this.currentPrice,
    this.message,
    this.rawData = const {},
  });

  /// Crea NotificationData desde un Map
  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      type: NotificationType.fromString(map['type'] as String?),
      symbol: map['symbol'] as String?,
      cryptoName: map['cryptoName'] as String? ?? map['name'] as String?,
      dropPercent: _parseDouble(map['dropPercent']),
      currentPrice: _parseDouble(map['currentPrice']),
      message: map['message'] as String?,
      rawData: map,
    );
  }

  /// Crea NotificationData desde un JSON string
  factory NotificationData.fromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return NotificationData.fromMap(map);
    } catch (e) {
      // Si falla el parsing JSON, intentar parsear como toString() de Map
      return NotificationData.fromPayloadString(json);
    }
  }

  /// Parsea un payload en formato string (resultado de Map.toString())
  /// Ejemplo: "{symbol: BTC, type: price_alert, cryptoName: Bitcoin}"
  factory NotificationData.fromPayloadString(String payload) {
    if (payload.isEmpty) {
      return const NotificationData(type: NotificationType.unknown);
    }

    try {
      // Remover llaves y espacios
      final cleaned = payload
          .replaceAll('{', '')
          .replaceAll('}', '')
          .trim();

      if (cleaned.isEmpty) {
        return const NotificationData(type: NotificationType.unknown);
      }

      final map = <String, dynamic>{};

      // Dividir por comas
      final pairs = cleaned.split(',');

      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          final value = keyValue[1].trim();
          map[key] = value;
        }
      }

      return NotificationData.fromMap(map);
    } catch (e) {
      return const NotificationData(type: NotificationType.unknown);
    }
  }

  /// Convierte a Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      if (symbol != null) 'symbol': symbol,
      if (cryptoName != null) 'cryptoName': cryptoName,
      if (dropPercent != null) 'dropPercent': dropPercent,
      if (currentPrice != null) 'currentPrice': currentPrice,
      if (message != null) 'message': message,
    };
  }

  /// Convierte a JSON string
  String toJson() => jsonEncode(toMap());

  /// Convierte a formato de payload string para notificaciones locales
  String toPayloadString() {
    final entries = toMap().entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return '{$entries}';
  }

  /// Helper para parsear doubles de manera segura
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Valida si los datos son suficientes para la navegación
  bool get isValidForNavigation {
    switch (type) {
      case NotificationType.priceAlert:
        return symbol != null;
      case NotificationType.general:
        return true;
      case NotificationType.unknown:
        return false;
    }
  }

  @override
  String toString() {
    return 'NotificationData(type: $type, symbol: $symbol, cryptoName: $cryptoName, '
        'dropPercent: $dropPercent, currentPrice: $currentPrice)';
  }
}
