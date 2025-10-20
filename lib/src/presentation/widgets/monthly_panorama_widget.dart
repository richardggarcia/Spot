import 'package:flutter/material.dart';
import '../../domain/entities/monthly_report.dart';

/// Widget para mostrar el panorama mensual completo con un diseño mejorado.
class MonthlyPanoramaWidget extends StatelessWidget {

  const MonthlyPanoramaWidget({super.key, required this.report});
  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade900,
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
                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            // Métrica Principal (Caída)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    'Caída Máxima',
                    style: textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.red.shade300 : Colors.red.shade800
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(maxOpp.deepDrop * 100).toStringAsFixed(1)}%',
                    style: textTheme.displaySmall?.copyWith(
                      color: isDark ? Colors.red.shade300 : Colors.red.shade800,
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
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
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
                color: isDark ? Colors.white60 : Colors.black54,
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

  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon, 
          size: 18, 
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white.withValues(alpha: 0.87) : null,
            ),
          ),
        ),
      ],
    );
  }
}
