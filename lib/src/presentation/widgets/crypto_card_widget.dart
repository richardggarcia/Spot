import 'package:flutter/material.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_metrics.dart';

/// Widget de tarjeta individual para mostrar información de criptomoneda
/// Muestra precio, caída, rebote y veredicto con indicadores visuales
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
    final hasAlert = metrics?.hasAlert ?? false;
    final isOpportunity = metrics?.isBuyOpportunity ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: hasAlert ? Colors.red[50] : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con símbolo y precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    crypto.symbol,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '\$${crypto.formattedPrice}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (hasAlert) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.notifications_active,
                          color: Colors.red[600],
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Métricas de caída y rebote
              if (metrics != null) ...[
                Row(
                  children: [
                    // Caída profunda
                    Expanded(
                      child: _MetricWidget(
                        label: 'Caída',
                        value: '${metrics!.deepDrop.toStringAsFixed(2)}%',
                        color: _getDropColor(metrics!.deepDrop),
                        icon: Icons.trending_down,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Rebote
                    Expanded(
                      child: _MetricWidget(
                        label: 'Rebote',
                        value: '${metrics!.rebound.toStringAsFixed(2)}%',
                        color: _getReboundColor(metrics!.rebound),
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Veredicto
                Row(
                  children: [
                    Icon(
                      isOpportunity ? Icons.star : Icons.info_outline,
                      size: 16,
                      color: isOpportunity
                          ? Colors.amber[600]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        metrics!.verdict ?? 'Analizando...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: metrics!.verdict == null
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Estado loading si no hay métricas
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey[400]!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calculando métricas...',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],

              // Indicador de alerta activa
              if (hasAlert) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ALERTA ACTIVA',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el color para la caída según su magnitud
  Color _getDropColor(double drop) {
    if (drop <= -8.0) return Colors.red[900]!;
    if (drop <= -5.0) return Colors.red[600]!;
    if (drop <= -3.0) return Colors.orange[600]!;
    if (drop <= -1.0) return Colors.yellow[700]!;
    return Colors.grey[600]!;
  }

  /// Obtiene el color para el rebote según su magnitud
  Color _getReboundColor(double rebound) {
    if (rebound >= 5.0) return Colors.green[700]!;
    if (rebound >= 3.0) return Colors.green[600]!;
    if (rebound >= 1.0) return Colors.lightGreen[600]!;
    return Colors.grey[600]!;
  }
}

/// Widget para mostrar una métrica individual
class _MetricWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricWidget({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
