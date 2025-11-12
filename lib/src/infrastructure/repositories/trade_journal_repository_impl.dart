import '../../core/utils/logger.dart';
import '../../domain/entities/trade_note.dart';
import '../../domain/ports/trade_journal_port.dart';
import '../../domain/repositories/trade_journal_repository.dart';

class TradeJournalRepositoryImpl implements TradeJournalRepository {
  TradeJournalRepositoryImpl({required TradeJournalPort journalPort})
    : _journalPort = journalPort;

  final TradeJournalPort _journalPort;

  @override
  Future<TradeNote> createEntry(TradeNoteDraft draft) async {
    AppLogger.info('Creating trade note for ${draft.symbol}');
    final raw = await _journalPort.createEntry(draft.toJson());
    return TradeNote.fromJson(raw);
  }

  @override
  Future<bool> deleteEntry(String id, {String? userId}) async {
    AppLogger.info('Deleting trade note $id');
    return _journalPort.deleteEntry(id, userId: userId);
  }

  @override
  Future<List<TradeNote>> getEntries({
    String? userId,
    String? symbol,
    String order = 'desc',
    int? limit,
  }) async {
    AppLogger.info('Fetching trade notes', {
      'symbol': symbol,
      'order': order,
      'limit': limit,
    });

    final rawEntries = await _journalPort.fetchEntries(
      userId: userId,
      symbol: symbol,
      order: order,
      limit: limit,
    );

    return rawEntries
        .map(TradeNote.fromJson)
        .where((note) => !_isPreferenceEntry(note))
        .toList(growable: false);
  }

  @override
  Future<TradeNote?> updateEntry(String id, TradeNoteUpdate update) async {
    AppLogger.info('Updating trade note $id');
    final raw = await _journalPort.updateEntry(
      id,
      update.toJson(),
      userId: update.userId,
    );

    if (raw == null) return null;
    return TradeNote.fromJson(raw);
  }
}

bool _isPreferenceEntry(TradeNote note) {
  final symbol = note.symbol.toUpperCase();
  if (note.side == 'preference') return true;
  return symbol == 'USER_PREFERENCES_CRYPTOS' ||
      symbol == 'USER_PREFERENCES_CARD_ORDER';
}
