import 'package:equatable/equatable.dart';

class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

class LoadJournalNotes extends JournalEvent {
  const LoadJournalNotes({this.symbol, this.userId, this.limit});

  final String? symbol;
  final String? userId;
  final int? limit;

  @override
  List<Object?> get props => [symbol, userId, limit];
}

class AddJournalNote extends JournalEvent {
  const AddJournalNote({
    required this.symbol,
    required this.entryPrice,
    required this.entryAt,
    this.side = 'buy',
    this.exitPrice,
    this.exitAt,
    this.size,
    this.notes = '',
    this.tags = const [],
    this.alertId,
    this.userId,
  });

  final String symbol;
  final double entryPrice;
  final DateTime entryAt;
  final String side;
  final double? exitPrice;
  final DateTime? exitAt;
  final double? size;
  final String notes;
  final List<String> tags;
  final String? alertId;
  final String? userId;

  @override
  List<Object?> get props => [
    symbol,
    entryPrice,
    entryAt,
    side,
    exitPrice,
    exitAt,
    size,
    notes,
    tags,
    alertId,
    userId,
  ];
}

class UpdateJournalNote extends JournalEvent {
  const UpdateJournalNote({
    required this.id,
    this.symbol,
    this.side,
    this.entryPrice,
    this.entryAt,
    this.exitPrice,
    this.exitAt,
    this.size,
    this.notes,
    this.tags,
    this.alertId,
    this.userId,
  });

  final String id;
  final String? symbol;
  final String? side;
  final double? entryPrice;
  final DateTime? entryAt;
  final double? exitPrice;
  final DateTime? exitAt;
  final double? size;
  final String? notes;
  final List<String>? tags;
  final String? alertId;
  final String? userId;

  @override
  List<Object?> get props => [
    id,
    symbol,
    side,
    entryPrice,
    entryAt,
    exitPrice,
    exitAt,
    size,
    notes,
    tags,
    alertId,
    userId,
  ];
}

class DeleteJournalNote extends JournalEvent {
  const DeleteJournalNote({required this.id, this.userId});

  final String id;
  final String? userId;

  @override
  List<Object?> get props => [id, userId];
}
