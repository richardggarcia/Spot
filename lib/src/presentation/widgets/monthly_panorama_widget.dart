import 'package:flutter/material.dart';
import '../../domain/entities/monthly_report.dart';

/// Widget para mostrar el panorama mensual completo
class MonthlyPanoramaWidget extends StatelessWidget {
  final MonthlyReport report;

  const MonthlyPanoramaWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              '🎯 Panorama Mensual',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const Divider(height: 24, thickness: 1.5),

            // Máxima oportunidad destacada
            if (report.maxOpportunity != null) ...[
              _buildMaxOpportunitySection(context),
              const SizedBox(height: 20),
            ],

            // Texto del panorama
            Text(
              report.panorama,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.5, // Mejora la legibilidad
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxOpportunitySection(BuildContext context) {
    final maxOpp = report.maxOpportunity!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MÁXIMA OPORTUNIDAD DEL MES',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Fecha',
            value:
                '${maxOpp.date.day} de ${report.monthName} (${maxOpp.weekday})',
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Precio Clave',
            value: '\$${maxOpp.opportunityPrice.toStringAsFixed(2)}',
            icon: Icons.monetization_on_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Caída Profunda',
                  value: '${(maxOpp.deepDrop * 100).toStringAsFixed(2)}%',
                  color: Colors.red.shade700,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Rebote',
                  value: '${(maxOpp.rebound * 100).toStringAsFixed(2)}%',
                  color: Colors.green.shade700,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (maxOpp.hasAlert)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withAlpha(77)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.red.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ALERTA ACTIVADA',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (maxOpp.verdict.isNotEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                '"${maxOpp.verdict}"',
                style: textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de fila de información, mejorado para alineación
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Widget de tarjeta de métrica, mejorado visualmente
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
