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

/// Item de noticia asociado a una alerta inteligente.
class NotificationNewsItem {
  const NotificationNewsItem({
    this.title,
    this.source,
    this.summary,
    this.url,
    this.publishedAt,
  });

  factory NotificationNewsItem.fromMap(Map<String, dynamic> map) =>
      NotificationNewsItem(
        title: map['title'] as String? ?? map['headline'] as String?,
        source: map['source'] is Map
            ? (map['source'] as Map)['name'] as String?
            : map['source'] as String?,
        summary: map['summary'] as String? ?? map['description'] as String?,
        url: map['url'] as String? ?? map['link'] as String?,
        publishedAt: map['publishedAt'] as String? ?? map['date'] as String?,
      );

  final String? title;
  final String? source;
  final String? summary;
  final String? url;
  final String? publishedAt;

  Map<String, dynamic> toMap() => {
    if (title != null) 'title': title,
    if (source != null) 'source': source,
    if (summary != null) 'summary': summary,
    if (url != null) 'url': url,
    if (publishedAt != null) 'publishedAt': publishedAt,
  };
}

class NotificationData {
  const NotificationData({
    required this.type,
    this.symbol,
    this.cryptoName,
    this.cause,
    this.analysisType,
    this.dropPercent,
    this.currentPrice,
    this.confidence,
    this.timeframe,
    this.analysisSummary,
    this.causeSummary,
    this.strategySummary,
    this.primaryNews,
    this.aiEngine,
    this.priceTargets,
    this.newsItems = const [],
    this.message,
    this.rawData = const {},
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    final parsedPriceTargets = _parsePriceTargets(map['priceTargets']);
    final parsedNewsItems = _parseNewsItems(
      map['newsItems'] ?? map['relatedNews'],
    );

    return NotificationData(
      type: NotificationType.fromString(map['type'] as String?),
      symbol: map['symbol'] as String?,
      cryptoName: map['cryptoName'] as String? ?? map['name'] as String?,
      cause: map['cause'] as String?,
      analysisType: map['analysisType'] as String?,
      dropPercent:
          _parseDouble(map['dropPercent']) ??
          _parseDouble(map['dropPercentValue']) ??
          _parseDouble(map['originalDrop']),
      currentPrice: _parseDouble(map['currentPrice']),
      confidence:
          _parseDouble(map['confidenceScore']) ??
          _parseDouble(map['confidence']),
      timeframe: map['timeframe'] as String?,
      analysisSummary: map['analysisSummary'] as String?,
      causeSummary: map['causeSummary'] as String? ?? map['cause'] as String?,
      strategySummary: map['strategySummary'] as String?,
      primaryNews: map['primaryNews'] as String?,
      aiEngine: map['aiEngine'] as String?,
      priceTargets: parsedPriceTargets,
      newsItems: parsedNewsItems,
      message: map['message'] as String?,
      rawData: map,
    );
  }

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

    // Intentar parsear como JSON completo
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return NotificationData.fromMap(decoded);
      }
    } catch (_) {
      // Ignorar y usar formato legacy
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
  final String? cause;
  final String? analysisType;
  final double? dropPercent;
  final double? currentPrice;
  final double? confidence;
  final String? timeframe;
  final String? analysisSummary;
  final String? causeSummary;
  final String? strategySummary;
  final String? primaryNews;
  final String? aiEngine;
  final Map<String, dynamic>? priceTargets;
  final List<NotificationNewsItem> newsItems;
  final String? message;
  final Map<String, dynamic> rawData;

  Map<String, dynamic> toMap() => {
    'type': type.value,
    if (symbol != null) 'symbol': symbol,
    if (cryptoName != null) 'cryptoName': cryptoName,
    if (cause != null) 'cause': cause,
    if (analysisType != null) 'analysisType': analysisType,
    if (dropPercent != null) 'dropPercent': dropPercent,
    if (currentPrice != null) 'currentPrice': currentPrice,
    if (confidence != null) 'confidence': confidence,
    if (timeframe != null) 'timeframe': timeframe,
    if (analysisSummary != null) 'analysisSummary': analysisSummary,
    if (causeSummary != null) 'causeSummary': causeSummary,
    if (strategySummary != null) 'strategySummary': strategySummary,
    if (primaryNews != null) 'primaryNews': primaryNews,
    if (aiEngine != null) 'aiEngine': aiEngine,
    if (priceTargets != null) 'priceTargets': priceTargets,
    if (newsItems.isNotEmpty)
      'newsItems': newsItems.map((item) => item.toMap()).toList(),
    if (message != null) 'message': message,
  };

  String toJson() => jsonEncode(toMap());

  String toPayloadString() => jsonEncode(toMap());

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll('%', '').trim();
      return double.tryParse(cleaned);
    }
    return null;
  }

  static Map<String, dynamic>? _parsePriceTargets(dynamic value) {
    if (value == null) return null;
    try {
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is String && value.isNotEmpty) {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (_) {
      // Ignorar errores de parseo
    }
    return null;
  }

  static List<NotificationNewsItem> _parseNewsItems(dynamic value) {
    if (value == null) return const [];

    try {
      if (value is String && value.isNotEmpty) {
        final decoded = jsonDecode(value);
        return _parseNewsItems(decoded);
      }

      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map(NotificationNewsItem.fromMap)
            .toList();
      }
    } catch (_) {
      // Ignorar errores
    }

    return const [];
  }

  double? get dropPercentAbs => dropPercent?.abs();

  bool get hasStrategy =>
      (strategySummary != null && strategySummary!.isNotEmpty) ||
      (priceTargets != null && priceTargets!.isNotEmpty);

  bool get hasNews =>
      (primaryNews != null && primaryNews!.isNotEmpty) || newsItems.isNotEmpty;

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
  String toString() =>
      'NotificationData(type: $type, symbol: $symbol, drop: $dropPercent, confidence: $confidence)';
}
