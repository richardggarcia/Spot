import '../repositories/trade_journal_repository.dart';

class DeleteTradeNoteParams {
  const DeleteTradeNoteParams({required this.id, this.userId});

  final String id;
  final String? userId;
}

class DeleteTradeNoteUseCase {
  const DeleteTradeNoteUseCase(this._repository);

  final TradeJournalRepository _repository;

  Future<bool> execute(DeleteTradeNoteParams params) =>
      _repository.deleteEntry(params.id, userId: params.userId);
}
