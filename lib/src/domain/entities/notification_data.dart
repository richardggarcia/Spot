import 'dart:convert';

/// Tipos de notificaciones soportadas
enum NotificationType {
  priceAlert('price_alert'),
  general('general'),
  unknown('unknown');

  const NotificationType(this.value);

  final String value;

  static NotificationType fromString(String? value) {
    if (value == null) return NotificationType.unknown;

    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.unknown,
    );
  }
}

class NotificationData {
  const NotificationData({
    required this.type,
    this.symbol,
    this.cryptoName,
    this.dropPercent,
    this.currentPrice,
    this.message,
    this.rawData = const {},
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) => NotificationData(
      type: NotificationType.fromString(map['type'] as String?),
      symbol: map['symbol'] as String?,
      cryptoName: map['cryptoName'] as String? ?? map['name'] as String?,
      dropPercent: _parseDouble(map['dropPercent']),
      currentPrice: _parseDouble(map['currentPrice']),
      message: map['message'] as String?,
      rawData: map,
    );

  factory NotificationData.fromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return NotificationData.fromMap(map);
    } catch (e) {
      return NotificationData.fromPayloadString(json);
    }
  }

  factory NotificationData.fromPayloadString(String payload) {
    if (payload.isEmpty) {
      return const NotificationData(type: NotificationType.unknown);
    }

    try {
      final cleaned = payload.replaceAll('{', '').replaceAll('}', '').trim();

      if (cleaned.isEmpty) {
        return const NotificationData(type: NotificationType.unknown);
      }

      final map = <String, dynamic>{};

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

  final NotificationType type;
  final String? symbol;
  final String? cryptoName;
  final double? dropPercent;
  final double? currentPrice;
  final String? message;
  final Map<String, dynamic> rawData;

  Map<String, dynamic> toMap() => {
      'type': type.value,
      if (symbol != null) 'symbol': symbol,
      if (cryptoName != null) 'cryptoName': cryptoName,
      if (dropPercent != null) 'dropPercent': dropPercent,
      if (currentPrice != null) 'currentPrice': currentPrice,
      if (message != null) 'message': message,
    };

  String toJson() => jsonEncode(toMap());

  String toPayloadString() {
    final entries = toMap().entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return '{$entries}';
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

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
  String toString() => 'NotificationData(type: $type, symbol: $symbol, cryptoName: $cryptoName, '
        'dropPercent: $dropPercent, currentPrice: $currentPrice)';
}
