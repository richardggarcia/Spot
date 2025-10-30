import '../entities/trade_note.dart';
import '../repositories/trade_journal_repository.dart';

class CreateTradeNoteParams {
  const CreateTradeNoteParams({
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

class CreateTradeNoteUseCase {
  const CreateTradeNoteUseCase(this._repository);

  final TradeJournalRepository _repository;

  Future<TradeNote> execute(CreateTradeNoteParams params) =>
      _repository.createEntry(
        TradeNoteDraft(
          symbol: params.symbol,
          entryPrice: params.entryPrice,
          entryAt: params.entryAt,
          side: params.side,
          exitPrice: params.exitPrice,
          exitAt: params.exitAt,
          size: params.size,
          notes: params.notes,
          tags: params.tags,
          attachments: params.attachments,
          alertId: params.alertId,
          userId: params.userId,
        ),
      );
}
