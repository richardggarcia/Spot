/// Puerto para interactuar con la fuente de datos del diario de operaciones.
abstract class TradeJournalPort {
  Future<List<Map<String, dynamic>>> fetchEntries({
    String? userId,
    String? symbol,
    String? order,
    int? limit,
  });

  Future<Map<String, dynamic>> createEntry(Map<String, dynamic> payload);

  Future<Map<String, dynamic>?> updateEntry(
    String id,
    Map<String, dynamic> payload, {
    String? userId,
  });

  Future<bool> deleteEntry(String id, {String? userId});
}
