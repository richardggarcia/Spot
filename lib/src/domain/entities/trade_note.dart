import 'package:equatable/equatable.dart';

class TradeAttachment extends Equatable {
  const TradeAttachment({required this.type, required this.url, this.title});

  factory TradeAttachment.fromJson(Map<String, dynamic> json) =>
      TradeAttachment(
        type: (json['type'] ?? '').toString(),
        url: (json['url'] ?? '').toString(),
        title: json['title']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    if (title != null) 'title': title,
  };

  final String type;
  final String url;
  final String? title;

  @override
  List<Object?> get props => [type, url, title];
}

class TradeNote extends Equatable {
  const TradeNote({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.entryAt,
    this.exitPrice,
    this.exitAt,
    this.size,
    this.notes = '',
    this.tags = const [],
    this.attachments = const [],
    this.alertId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TradeNote.fromJson(Map<String, dynamic> json) => TradeNote(
    id: (json['id'] ?? '').toString(),
    userId: (json['userId'] ?? '').toString(),
    symbol: (json['symbol'] ?? '').toString(),
    side: (json['side'] ?? 'buy').toString(),
    entryPrice: _parseDouble(json['entryPrice']),
    entryAt: _parseDate(json['entryAt']),
    exitPrice: json['exitPrice'] != null
        ? _parseDouble(json['exitPrice'])
        : null,
    exitAt: json['exitAt'] != null ? _parseDate(json['exitAt']) : null,
    size: json['size'] != null ? _parseDouble(json['size']) : null,
    notes: (json['notes'] ?? '').toString(),
    tags: (json['tags'] as List<dynamic>? ?? [])
        .map((tag) => tag.toString())
        .toList(),
    attachments: (json['attachments'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TradeAttachment.fromJson)
        .toList(),
    alertId: json['alertId']?.toString(),
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'symbol': symbol,
    'side': side,
    'entryPrice': entryPrice,
    'exitPrice': exitPrice,
    'size': size,
    'entryAt': entryAt.toIso8601String(),
    'exitAt': exitAt?.toIso8601String(),
    'notes': notes,
    'tags': tags,
    'attachments': attachments.map((item) => item.toJson()).toList(),
    'alertId': alertId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  TradeNote copyWith({
    String? id,
    String? userId,
    String? symbol,
    String? side,
    double? entryPrice,
    DateTime? entryAt,
    double? exitPrice,
    DateTime? exitAt,
    double? size,
    String? notes,
    List<String>? tags,
    List<TradeAttachment>? attachments,
    String? alertId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TradeNote(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    symbol: symbol ?? this.symbol,
    side: side ?? this.side,
    entryPrice: entryPrice ?? this.entryPrice,
    entryAt: entryAt ?? this.entryAt,
    exitPrice: exitPrice ?? this.exitPrice,
    exitAt: exitAt ?? this.exitAt,
    size: size ?? this.size,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
    attachments: attachments ?? this.attachments,
    alertId: alertId ?? this.alertId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException('Invalid numeric value: $value');
    }
    return parsed;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      throw const FormatException('Date value is required');
    }
    if (value is DateTime) return value.toUtc();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException('Invalid date value: $value');
    }
    return parsed.toUtc();
  }

  final String id;
  final String userId;
  final String symbol;
  final String side;
  final double entryPrice;
  final double? exitPrice;
  final double? size;
  final DateTime entryAt;
  final DateTime? exitAt;
  final String notes;
  final List<String> tags;
  final List<TradeAttachment> attachments;
  final String? alertId;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    symbol,
    side,
    entryPrice,
    exitPrice,
    size,
    entryAt,
    exitAt,
    notes,
    tags,
    attachments,
    alertId,
    createdAt,
    updatedAt,
  ];
}
