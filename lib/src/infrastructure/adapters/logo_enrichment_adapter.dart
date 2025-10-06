import '../../core/utils/logger.dart';
import '../../domain/entities/crypto.dart';
import 'coingecko_price_adapter.dart'; // Reutilizamos el mapeo de ID

/// Adapter para enriquecer una lista de criptos con sus logos.
class LogoEnrichmentAdapter {
  final CoinGeckoPriceAdapter _coinGeckoAdapter;

  LogoEnrichmentAdapter(this._coinGeckoAdapter);

  /// Toma una lista de Crypto, obtiene sus logos de CoinGecko y devuelve la lista enriquecida.
  Future<List<Crypto>> enrichLogos(List<Crypto> cryptos) async {
    if (cryptos.isEmpty) return [];

    // Si ya todas tienen logo, no hacer nada.
    if (cryptos.every((c) => c.imageUrl != null)) {
      return cryptos;
    }

    try {
      // Obtener la información completa de CoinGecko
      final symbols = cryptos.map((c) => c.symbol).toList();
      final coingeckoData = await _coinGeckoAdapter.getPricesForSymbols(symbols);

      // Crear un mapa de Symbol -> ImageUrl para búsqueda rápida
      final logoMap = { for (var data in coingeckoData) data.symbol : data.imageUrl };

      // Crear una nueva lista de cryptos con la URL del logo
      final enrichedCryptos = cryptos.map((crypto) {
        final imageUrl = logoMap[crypto.symbol];
        if (imageUrl != null) {
          // Usamos copyWith para crear una nueva instancia inmutable
          return crypto.copyWith(imageUrl: imageUrl);
        }
        return crypto;
      }).toList();

      return enrichedCryptos;
    } catch (e) {
      // Si falla la obtención de logos, devolvemos la lista original.
      // No queremos que la app falle solo por no poder mostrar un logo.
      AppLogger.error('Error enriching logos: $e');
      return cryptos;
    }
  }
}
