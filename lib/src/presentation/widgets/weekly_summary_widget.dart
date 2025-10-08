import 'package:flutter/material.dart';
import '../../domain/entities/weekly_summary.dart';

/// Widget para mostrar el resumen semanal de volatilidad con un diseño mejorado.
class WeeklySummaryWidget extends StatelessWidget {
  final List<WeeklySummary> weeks;

  const WeeklySummaryWidget({super.key, required this.weeks});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip
          .antiAlias, // Asegura que el contenido respete los bordes redondeados
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Center(
              child: Text(
                '📈 Resumen Semanal de Volatilidad',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildTable(context),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        ...weeks.map((week) {
          final index = weeks.indexOf(week);
          return _WeekRow(week: week, isLastRow: index == weeks.length - 1);
        }),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headerStyle = textTheme.labelMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.blue.shade800,
      child: Row(
        children: [
          _HeaderCell(title: 'Semana', style: headerStyle, flex: 2),
          _HeaderCell(title: 'Mayor Caída ↓', style: headerStyle, flex: 3),
          _HeaderCell(title: 'Rebote Prom. ↑', style: headerStyle, flex: 3),
          _HeaderCell(title: 'Punto Clave', style: headerStyle, flex: 4),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final int flex;

  const _HeaderCell({required this.title, this.style, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget de fila para una semana con diseño mejorado
class _WeekRow extends StatelessWidget {
  final WeeklySummary week;
  final bool isLastRow;

  const _WeekRow({required this.week, this.isLastRow = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final keyPoint = week.keyBuyingPoint;
    final hasOpportunity = week.maxDeepDrop <= -0.05;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: hasOpportunity
            ? Colors.orange.withAlpha(13)
            : Colors.transparent,
        border: isLastRow
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Número de semana
          Expanded(
            flex: 2,
            child: Text(
              '#${week.weekNumber}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Mayor caída
          Expanded(
            flex: 3,
            child: Text(
              '${(week.maxDeepDrop * 100).toStringAsFixed(1)}%',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getDeepDropColor(week.maxDeepDrop),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Rebote promedio
          Expanded(
            flex: 3,
            child: Text(
              '${(week.averageRebound * 100).toStringAsFixed(1)}%',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Punto de compra clave
          Expanded(
            flex: 4,
            child: keyPoint != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${week.keyBuyingPrice!.toStringAsFixed(0)}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        week.description,
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : Text(
                    '-',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
      ),
    );
  }

  Color _getDeepDropColor(double drop) {
    if (drop <= -0.06) return Colors.red.shade900;
    if (drop <= -0.05) return Colors.red.shade700;
    if (drop <= -0.03) return Colors.orange.shade800;
    return Colors.grey.shade700;
  }
}
