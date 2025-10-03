import 'package:flutter/material.dart';
import '../../domain/entities/daily_analysis.dart';

/// Widget para mostrar una fila de análisis diario en la tabla, con diseño mejorado.
class DailyRowWidget extends StatelessWidget {
  final DailyAnalysis analysis;

  const DailyRowWidget({super.key, required this.analysis});

  /// Constructor para el header de la tabla.
  static Widget header(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headerStyle = textTheme.labelMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade900, width: 2),
        ),
      ),
      child: Row(
        children: [
          _HeaderCell(text: 'Fecha', style: headerStyle, flex: 3),
          _HeaderCell(text: 'Día', style: headerStyle, flex: 2),
          _HeaderCell(
            text: 'Cierre Neto',
            style: headerStyle,
            flex: 3,
            alignment: TextAlign.right,
          ),
          _HeaderCell(
            text: 'Caída ↓',
            style: headerStyle,
            flex: 3,
            alignment: TextAlign.right,
          ),
          _HeaderCell(
            text: 'Precio Opp.',
            style: headerStyle,
            flex: 3,
            alignment: TextAlign.right,
          ),
          _HeaderCell(
            text: 'Rebote ↑',
            style: headerStyle,
            flex: 3,
            alignment: TextAlign.right,
          ),
          _HeaderCell(text: 'Veredicto', style: headerStyle, flex: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateStr =
        '${analysis.date.day.toString().padLeft(2, '0')}/${analysis.date.month.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: analysis.hasAlert
            ? Colors.orange.withAlpha(25)
            : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fecha y Día
          Expanded(
            flex: 3,
            child: Text(
              dateStr,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              analysis.weekday.substring(0, 3),
              style: textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ),

          // Cierre Neto
          _DataCell(
            text: '${(analysis.netChange * 100).toStringAsFixed(1)}%',
            flex: 3,
            style: textTheme.bodyMedium?.copyWith(
              color: _getChangeColor(analysis.netChange),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          // Caída Profunda
          _DataCell(
            text: '${(analysis.deepDrop * 100).toStringAsFixed(1)}%',
            flex: 3,
            style: textTheme.bodyMedium?.copyWith(
              color: _getDeepDropColor(analysis.deepDrop),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          // Precio Oportunidad
          _DataCell(
            text: '\$${analysis.opportunityPrice.toStringAsFixed(0)}',
            flex: 3,
            style: textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),

          // Rebote
          _DataCell(
            text: '${(analysis.rebound * 100).toStringAsFixed(1)}%',
            flex: 3,
            style: textTheme.bodyMedium?.copyWith(
              color: _getReboundColor(analysis.rebound),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          // Veredicto
          Expanded(
            flex: 5,
            child: Text(
              analysis.verdict,
              style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Color _getChangeColor(double change) {
    return change >= 0 ? Colors.green.shade700 : Colors.red.shade700;
  }

  Color _getDeepDropColor(double drop) {
    if (drop <= -0.06) return Colors.red.shade900;
    if (drop <= -0.05) return Colors.red.shade700;
    if (drop <= -0.03) return Colors.orange.shade800;
    return Colors.grey.shade700;
  }

  Color _getReboundColor(double rebound) {
    if (rebound >= 0.05) return Colors.green.shade800;
    if (rebound >= 0.03) return Colors.green.shade700;
    return Colors.green.shade600;
  }
}

/// Celda para el header de la tabla
class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextStyle? style;
  final TextAlign alignment;

  const _HeaderCell({
    required this.text,
    this.flex = 1,
    this.style,
    this.alignment = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(text, style: style, textAlign: alignment, maxLines: 2),
      ),
    );
  }
}

/// Celda para datos de la tabla
class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextStyle? style;

  const _DataCell({required this.text, this.flex = 1, this.style});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.right,
          maxLines: 2,
        ),
      ),
    );
  }
}
