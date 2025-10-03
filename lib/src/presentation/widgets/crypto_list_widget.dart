import 'package:flutter/material.dart';
import '../../domain/entities/crypto.dart';

/// Widget para mostrar lista de criptomonedas
class CryptoListWidget extends StatelessWidget {
  final List<Crypto> cryptos;
  final bool isRefreshing;

  const CryptoListWidget({
    super.key,
    required this.cryptos,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cryptos.isEmpty) {
      return const _EmptyStateWidget();
    }

    return ListView.builder(
      itemCount: cryptos.length,
      itemBuilder: (context, index) {
        final crypto = cryptos[index];
        return CryptoTileWidget(crypto: crypto);
      },
    );
  }
}

/// Widget para mostrar una criptomoneda individual
class CryptoTileWidget extends StatelessWidget {
  final Crypto crypto;

  const CryptoTileWidget({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: crypto.isPositive ? Colors.green : Colors.red,
          child: Icon(
            crypto.isPositive ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
          ),
        ),
        title: Text(
          crypto.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          crypto.symbol.replaceAll('USDT', ''),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              crypto.formattedPrice,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: crypto.isPositive ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                crypto.formattedChangePercent,
                style: TextStyle(
                  color: crypto.isPositive
                      ? Colors.green[800]
                      : Colors.red[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para estado vacío
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.currency_exchange, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay datos disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta refrescar los datos',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
