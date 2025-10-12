import 'package:flutter/material.dart';
import '../../domain/entities/crypto.dart';
import '../../domain/entities/daily_metrics.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// Widget de tarjeta individual para mostrar información de criptomoneda.
/// Diseño v4: Adaptado al nuevo tema profesional de trading.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- SECCIÓN 1: DATOS DE MERCADO ---
              _buildMarketData(context),
              
              // --- SECCIÓN 2: ANÁLISIS INTERNO ---
              if (metrics != null) ...[
                Divider(
                  height: 24,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                _buildAnalysisData(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la sección de datos de mercado (logo, precio, cambio).
  Widget _buildMarketData(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final changeColor = crypto.isPositive
        ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
        : (isDark ? AppColors.darkBearish : AppColors.lightBearish);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: Logo, Símbolo y Precio
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo de la moneda
                if (crypto.imageUrl != null)
                  Image.network(
                    crypto.imageUrl!,
                    height: 32,
                    width: 32,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.currency_bitcoin,
                      size: 32,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  )
                else
                  Icon(
                    Icons.currency_bitcoin,
                    size: 32,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                
                const SizedBox(width: 12),
                
                // Símbolo y Nombre
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crypto.symbol,
                      style: AppTextStyles.h4.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      crypto.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Precio
            Text(
              '\$${crypto.formattedPrice}',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),

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
              style: AppTextStyles.bodyLarge.copyWith(
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '24h',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la sección de análisis (veredicto, oportunidad).
  Widget _buildAnalysisData(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verdict = metrics!.verdict ?? _getDefaultVerdict(metrics!);
    final iconInfo = _getVerdictIcon(metrics!, isDark);

    return Row(
      children: [
        Icon(iconInfo.icon, color: iconInfo.color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            verdict,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
  ({IconData icon, Color color}) _getVerdictIcon(DailyMetrics metrics, bool isDark) {
    if (metrics.isBuyOpportunity) {
      return (
        icon: Icons.star,
        color: isDark ? AppColors.darkOpportunity : AppColors.lightOpportunity,
      );
    }
    if (metrics.hasAlert) {
      return (
        icon: Icons.warning,
        color: isDark ? AppColors.darkAlert : AppColors.lightAlert,
      );
    }
    if (metrics.deepDrop <= -0.015) {
      return (
        icon: Icons.visibility,
        color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
      );
    }
    return (
      icon: Icons.info_outline,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
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
