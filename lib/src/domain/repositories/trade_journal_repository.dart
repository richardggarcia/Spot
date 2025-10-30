import '../entities/trade_note.dart';

class TradeNoteDraft {
  const TradeNoteDraft({
    required this.symbol,
    required this.entryPrice,
    required this.entryAt,
    this.side = 'buy',
    this.exitPrice,
    this.exitAt,
    this.size,
    this.notes = '',
    this.tags = const [],
    this.attachments = const [],
    this.alertId,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'side': side,
    'entryPrice': entryPrice,
    'entryAt': entryAt.toIso8601String(),
    if (exitPrice != null) 'exitPrice': exitPrice,
    if (exitAt != null) 'exitAt': exitAt?.toIso8601String(),
    if (size != null) 'size': size,
    'notes': notes,
    if (tags.isNotEmpty) 'tags': tags,
    if (attachments.isNotEmpty)
      'attachments': attachments.map((item) => item.toJson()).toList(),
    if (alertId != null) 'alertId': alertId,
    if (userId != null) 'userId': userId,
  };

  final String symbol;
  final double entryPrice;
  final DateTime entryAt;
  final String side;
  final double? exitPrice;
  final DateTime? exitAt;
  final double? size;
  final String notes;
  final List<String> tags;
  final List<TradeAttachment> attachments;
  final String? alertId;
  final String? userId;
}

class TradeNoteUpdate {
  const TradeNoteUpdate({
    this.symbol,
    this.side,
    this.entryPrice,
    this.entryAt,
    this.exitPrice,
    this.exitAt,
    this.size,
    this.notes,
    this.tags,
    this.attachments,
    this.alertId,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
    if (symbol != null) 'symbol': symbol,
    if (side != null) 'side': side,
    if (entryPrice != null) 'entryPrice': entryPrice,
    if (entryAt != null) 'entryAt': entryAt?.toIso8601String(),
    if (exitPrice != null) 'exitPrice': exitPrice,
    if (exitAt != null) 'exitAt': exitAt?.toIso8601String(),
    if (size != null) 'size': size,
    if (notes != null) 'notes': notes,
    if (tags != null) 'tags': tags,
    if (attachments != null)
      'attachments': attachments!.map((item) => item.toJson()).toList(),
    if (alertId != null) 'alertId': alertId,
    if (userId != null) 'userId': userId,
  };

  final String? symbol;
  final String? side;
  final double? entryPrice;
  final DateTime? entryAt;
  final double? exitPrice;
  final DateTime? exitAt;
  final double? size;
  final String? notes;
  final List<String>? tags;
  final List<TradeAttachment>? attachments;
  final String? alertId;
  final String? userId;
}

abstract class TradeJournalRepository {
  Future<List<TradeNote>> getEntries({
    String? userId,
    String? symbol,
    String order,
    int? limit,
  });

  Future<TradeNote> createEntry(TradeNoteDraft draft);

  Future<TradeNote?> updateEntry(String id, TradeNoteUpdate update);

  Future<bool> deleteEntry(String id, {String? userId});
}
