import 'package:flutter/material.dart';
import '../../domain/entities/monthly_report.dart';

/// Widget para mostrar el panorama mensual completo con un diseño mejorado.
class MonthlyPanoramaWidget extends StatelessWidget {
  final MonthlyReport report;

  const MonthlyPanoramaWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Título
            Text(
              '🎯 Panorama Mensual',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Máxima oportunidad destacada
            if (report.maxOpportunity != null) ...[
              _buildMaxOpportunitySection(context),
              const Divider(height: 32, thickness: 1),
            ],

            // Texto del panorama
            Text(
              report.panorama,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left, // Mejor para leer párrafos largos
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxOpportunitySection(BuildContext context) {
    final maxOpp = report.maxOpportunity!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Métrica Principal (Caída)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    'Caída Máxima',
                    style: textTheme.labelMedium?.copyWith(color: Colors.red.shade800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(maxOpp.deepDrop * 100).toStringAsFixed(1)}%',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Separador Vertical
            Container(
              height: 60,
              width: 1,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),

            // Otras Métricas
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: '${maxOpp.date.day} de ${report.monthName}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.show_chart_outlined,
                    text: 'Rebote: ${(maxOpp.rebound * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.monetization_on_outlined,
                    text: 'Precio: \$${maxOpp.opportunityPrice.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
        if (maxOpp.verdict.isNotEmpty) ...[
          const SizedBox(height: 16),
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
    );
  }
}

/// Widget de fila de información con icono y texto.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
