import 'package:flutter/material.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_metrics.dart';

/// Widget de tarjeta individual para mostrar información de criptomoneda.
/// Diseño v3: Muestra datos de mercado claros y el análisis de oportunidad.
class CryptoCardWidget extends StatelessWidget {
  final Crypto crypto;
  final DailyMetrics? metrics;
  final VoidCallback? onTap;

  const CryptoCardWidget({
    super.key,
    required this.crypto,
    this.metrics,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPositive = crypto.priceChange24h >= 0;
    final changeColor = isPositive ? Colors.green[700] : Colors.red[700];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN 1: DATOS DE MERCADO ---
              _buildMarketData(textTheme, changeColor),
              
              // --- SECCIÓN 2: ANÁLISIS INTERNO ---
              if (metrics != null) ...[
                const Divider(height: 24, thickness: 0.5),
                _buildAnalysisData(textTheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la sección de datos de mercado (logo, precio, cambio).
  Widget _buildMarketData(TextTheme textTheme, Color? changeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: Logo, Símbolo y Precio
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                // Logo de la moneda
                if (crypto.imageUrl != null)
                  Image.network(
                    crypto.imageUrl!,
                    height: 28,
                    width: 28,
                    errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, size: 28),
                  )
                else
                  const Icon(Icons.currency_bitcoin, size: 28),
                
                const SizedBox(width: 12),
                
                // Símbolo
                Text(
                  crypto.symbol,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // Precio
            Text(
              '\$${crypto.formattedPrice}',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        
        const SizedBox(height: 8),

        // Fila 2: Cambio 24h (%, $)
        Row(
          children: [
            Icon(
              crypto.isPositive ? Icons.trending_up : Icons.trending_down,
              color: changeColor,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '${crypto.priceChange24h.toStringAsFixed(2)} (${crypto.formattedChangePercent})',
              style: textTheme.titleMedium?.copyWith(
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Hoy',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la sección de análisis (veredicto, oportunidad).
  Widget _buildAnalysisData(TextTheme textTheme) {
    final verdict = metrics!.verdict ?? _getDefaultVerdict(metrics!);
    final icon = _getVerdictIcon(metrics!);

    return Row(
      children: [
        Icon(icon.icon, color: icon.color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            verdict,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Obtiene el icono y color según el veredicto.
  ({IconData icon, Color color}) _getVerdictIcon(DailyMetrics metrics) {
    if (metrics.isBuyOpportunity) {
      return (icon: Icons.star, color: Colors.amber.shade700);
    }
    if (metrics.hasAlert) {
      return (icon: Icons.warning, color: Colors.orange.shade700);
    }
    if (metrics.deepDrop <= -0.015) {
      return (icon: Icons.visibility, color: Colors.blue.shade700);
    }
    return (icon: Icons.info_outline, color: Colors.grey.shade600);
  }

  /// Genera un veredicto por defecto si el LLM no provee uno.
  String _getDefaultVerdict(DailyMetrics metrics) {
    if (metrics.isBuyOpportunity) {
      return 'Oportunidad: Caída fuerte del ${metrics.formattedDeepDrop}. Monitorear.';
    }
    if (metrics.hasAlert) {
      return 'Alerta: Caída significativa del ${metrics.formattedDeepDrop}.';
    }
    if (metrics.deepDrop <= -0.015) {
      return 'Monitorear: Caída leve del ${metrics.formattedDeepDrop}.';
    }
    if (metrics.rebound >= 0.03) {
      return 'Recuperación del ${metrics.formattedRebound} en curso.';
    }
    return 'Sin movimientos significativos.';
  }
}
