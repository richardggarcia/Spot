import '../entities/trade_note.dart';
import '../repositories/trade_journal_repository.dart';

class UpdateTradeNoteParams {
  const UpdateTradeNoteParams({
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
    this.attachments,
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
  final List<TradeAttachment>? attachments;
  final String? alertId;
  final String? userId;
}

class UpdateTradeNoteUseCase {
  const UpdateTradeNoteUseCase(this._repository);

  final TradeJournalRepository _repository;

  Future<TradeNote?> execute(UpdateTradeNoteParams params) =>
      _repository.updateEntry(
        params.id,
        TradeNoteUpdate(
          symbol: params.symbol,
          side: params.side,
          entryPrice: params.entryPrice,
          entryAt: params.entryAt,
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
