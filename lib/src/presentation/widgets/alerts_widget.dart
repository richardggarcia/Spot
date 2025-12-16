import 'package:flutter/material.dart';
import '../../domain/entities/daily_metrics.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// Widget para mostrar lista de alertas
class AlertsWidget extends StatelessWidget {
  const AlertsWidget({
    super.key,
    required this.alerts,
    this.isRefreshing = false,
    this.showOpportunities = false,
  });
  final List<DailyMetrics> alerts;
  final bool isRefreshing;
  final bool showOpportunities;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const _EmptyAlertsWidget();
    }

    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return AlertTileWidget(
          alert: alert,
          showOpportunityBadge: showOpportunities,
        );
      },
    );
  }
}

/// Widget para mostrar una alerta individual
class AlertTileWidget extends StatelessWidget {
  const AlertTileWidget({
    super.key,
    required this.alert,
    this.showOpportunityBadge = false,
  });
  final DailyMetrics alert;
  final bool showOpportunityBadge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        isThreeLine: true,
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getAlertColor(context, isDark).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                color: _getAlertColor(context, isDark),
              ),
            ),
            if (showOpportunityBadge)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkOpportunity : AppColors.lightOpportunity,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.star, color: Colors.white, size: 10),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                alert.crypto.name,
                style: AppTextStyles.h4.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                overflow: TextOverflow.fade,
                softWrap: true,
              ),
            ),
            if (alert.dropSeverity.index >= DropSeverity.high.index)
              Flexible(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBearish : AppColors.lightBearish,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ALERTA',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.crypto.symbol.replaceAll('USDT', ''),
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  label: 'Caída',
                  value: alert.formattedDeepDrop,
                  isNegative: true,
                ),
                _MetricChip(
                  label: 'Rebote',
                  value: alert.formattedRebound,
                  isNegative: false,
                ),
              ],
            ),
            if (alert.verdict != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColors.darkAccentPrimary
                          : AppColors.lightAccentPrimary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isDark
                            ? AppColors.darkAccentPrimary
                            : AppColors.lightAccentPrimary)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: isDark
                          ? AppColors.darkAccentPrimary
                          : AppColors.lightAccentPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${alert.verdict}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: SizedBox(
          width: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  alert.crypto.formattedPrice,
                  style: AppTextStyles.priceMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  alert.crypto.formattedChangePercent,
                  style: alert.crypto.isPositive
                      ? AppTextStyles.bullish(context)
                      : AppTextStyles.bearish(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAlertColor(BuildContext context, bool isDark) {
    switch (alert.dropSeverity) {
      case DropSeverity.severe:
        return isDark ? AppColors.darkBearish : AppColors.lightBearish;
      case DropSeverity.high:
        return isDark ? AppColors.darkAlert : AppColors.lightAlert;
      case DropSeverity.moderate:
        return isDark ? AppColors.darkWarning : AppColors.lightWarning;
      case DropSeverity.low:
        return isDark
            ? AppColors.darkAccentPrimary
            : AppColors.lightAccentPrimary;
      case DropSeverity.minimal:
        return isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
    }
  }
}

/// Widget para mostrar métricas
class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.isNegative,
  });
  final String label;
  final String value;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isNegative
            ? (isDark ? AppColors.darkBearish : AppColors.lightBearish)
                  .withValues(alpha: 0.2)
            : (isDark ? AppColors.darkBullish : AppColors.lightBullish)
                  .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: isNegative
              ? (isDark ? AppColors.darkBearish : AppColors.lightBearish)
              : (isDark ? AppColors.darkBullish : AppColors.lightBullish),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Widget para estado vacío de alertas
class _EmptyAlertsWidget extends StatelessWidget {
  const _EmptyAlertsWidget();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_off, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'Sin alertas activas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}
