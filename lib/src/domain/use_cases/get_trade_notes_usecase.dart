import '../entities/trade_note.dart';
import '../repositories/trade_journal_repository.dart';

class GetTradeNotesParams {
  const GetTradeNotesParams({
    this.userId,
    this.symbol,
    this.order = 'desc',
    this.limit,
  });

  final String? userId;
  final String? symbol;
  final String order;
  final int? limit;
}

class GetTradeNotesUseCase {
  const GetTradeNotesUseCase(this._repository);

  final TradeJournalRepository _repository;

  Future<List<TradeNote>> execute(GetTradeNotesParams params) =>
      _repository.getEntries(
        userId: params.userId,
        symbol: params.symbol,
        order: params.order,
        limit: params.limit,
      );
}
