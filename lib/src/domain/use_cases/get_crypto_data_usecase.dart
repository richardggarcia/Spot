import '../entities/crypto.dart';
import '../repositories/crypto_repository.dart';

/// Caso de uso para obtener datos de criptomonedas
/// Orquesta la lógica de negocio para obtener datos de mercado
class GetCryptoDataUseCase {

  GetCryptoDataUseCase(this._cryptoRepository);
  final CryptoRepository _cryptoRepository;

  /// Ejecuta el caso de uso: obtiene todas las criptomonedas
  Future<List<Crypto>> execute() async {
    try {
      return await _cryptoRepository.getAllCryptos();
    } catch (e) {
      throw Exception('Error al obtener datos de criptomonedas: $e');
    }
  }

  /// Ejecuta el caso de uso: obtiene una criptomoneda específica
  Future<Crypto?> executeBySymbol(String symbol) async {
    if (symbol.isEmpty) {
      throw ArgumentError('El símbolo no puede estar vacío');
    }

    try {
      return await _cryptoRepository.getCryptoBySymbol(symbol);
    } catch (e) {
      throw Exception('Error al obtener datos de $symbol: $e');
    }
  }

  /// Ejecuta el caso de uso: refresca todos los datos
  Future<List<Crypto>> executeRefresh() async {
    try {
      return await _cryptoRepository.refreshAllCryptos();
    } catch (e) {
      throw Exception('Error al refrescar datos: $e');
    }
  }
}
