import 'package:flutter/material.dart';
import '../../domain/entities/daily_metrics.dart';

/// Widget para mostrar lista de alertas
class AlertsWidget extends StatelessWidget {
  final List<DailyMetrics> alerts;
  final bool isRefreshing;
  final bool showOpportunities;

  const AlertsWidget({
    super.key,
    required this.alerts,
    this.isRefreshing = false,
    this.showOpportunities = false,
  });

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
  final DailyMetrics alert;
  final bool showOpportunityBadge;

  const AlertTileWidget({
    super.key,
    required this.alert,
    this.showOpportunityBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getAlertColor(context).withValues(alpha: 0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: _getAlertColor(context),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
              ),
            ),
            if (showOpportunityBadge)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                alert.crypto.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (alert.dropSeverity.index >= DropSeverity.high.index)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ALERTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              alert.crypto.symbol.replaceAll('USDT', ''),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _MetricChip(
                  label: 'Caída',
                  value: alert.formattedDeepDrop,
                  isNegative: true,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  label: 'Rebote',
                  value: alert.formattedRebound,
                  isNegative: false,
                ),
              ],
            ),
            if (alert.verdict != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Análisis: ${alert.verdict}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              alert.crypto.formattedPrice,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              alert.crypto.formattedChangePercent,
              style: TextStyle(
                color: alert.crypto.isPositive ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(BuildContext context) {
    switch (alert.dropSeverity) {
      case DropSeverity.severe:
        return Colors.red;
      case DropSeverity.high:
        return Colors.orange;
      case DropSeverity.moderate:
        return Colors.amber;
      case DropSeverity.low:
        return Colors.blue;
      case DropSeverity.minimal:
        return Colors.grey;
    }
  }
}

/// Widget para mostrar métricas
class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isNegative ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: isNegative ? Colors.red[800] : Colors.green[800],
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
  Widget build(BuildContext context) {
    return const Center(
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
}
