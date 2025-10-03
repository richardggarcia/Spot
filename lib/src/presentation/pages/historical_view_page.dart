import 'package:flutter/material.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/weekly_summary.dart';
import '../../domain/entities/daily_analysis.dart';
import '../../infrastructure/adapters/binance_price_adapter.dart';
import '../../domain/services/historical_analysis_service.dart';
import '../widgets/weekly_summary_widget.dart';
import '../widgets/monthly_panorama_widget.dart';

/// Página de vista histórica con un diseño mejorado y optimizado.
class HistoricalViewPage extends StatefulWidget {
  final String symbol;
  final String cryptoName;

  const HistoricalViewPage({
    super.key,
    required this.symbol,
    required this.cryptoName,
  });

  @override
  State<HistoricalViewPage> createState() => _HistoricalViewPageState();
}

class _HistoricalViewPageState extends State<HistoricalViewPage> {
  final _priceAdapter = BinancePriceAdapter();
  final _analysisService = HistoricalAnalysisService();

  MonthlyReport? _report;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final candles = await _priceAdapter.getHistoricalData(
        widget.symbol,
        days: 30,
      );
      if (!mounted) return;

      final report = _analysisService.generateMonthlyReport(
        symbol: widget.symbol,
        cryptoName: widget.cryptoName,
        candles: candles,
      );

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadHistoricalData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('${widget.cryptoName} - Histórico'),
              backgroundColor: Colors.blue.shade800,
              floating: true,
              pinned: true,
              snap: false,
            ),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos históricos...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar los datos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadHistoricalData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_report == null) {
      return const SliverFillRemaining(
        child: Center(child: Text('No hay datos disponibles')),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildHeader(context),
        MonthlyPanoramaWidget(report: _report!),
        WeeklySummaryWidget(weeks: _report!.weeks),
        _buildWeeklyDetailsTitle(context),
        ..._report!.weeks.map((week) => _buildWeekSection(context, week)),
        const SizedBox(height: 40), // Espacio al final
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _report!.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Análisis de la acción del precio para ${widget.cryptoName} (${widget.symbol}) en ${_report!.monthName} ${_report!.year}.',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDetailsTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        '📅 Detalle Diario por Semana',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _buildWeekSection(BuildContext context, WeeklySummary week) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: Colors.grey.shade50,
        collapsedBackgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'S${week.weekNumber}',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    week.description,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${week.days.length} días',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: week.days.map((day) => _DayCard(analysis: day)).toList(),
      ),
    );
  }
}

/// Widget compacto para mostrar análisis diario (3 líneas)
class _DayCard extends StatelessWidget {
  final DailyAnalysis analysis;

  const _DayCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateStr =
        '${analysis.date.day.toString().padLeft(2, '0')}/${analysis.date.month.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: analysis.hasAlert
            ? Colors.orange.withAlpha(20)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: analysis.hasAlert
              ? Colors.orange.shade200
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea 1: Fecha + Día + Caída
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    dateStr,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    analysis.weekday.substring(0, 3),
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.arrow_downward, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '${(analysis.deepDrop * 100).toStringAsFixed(1)}%',
                    style: textTheme.titleSmall?.copyWith(
                      color: _getDeepDropColor(analysis.deepDrop),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Línea 2: Precio Oportunidad
          Text(
            'Precio Oportunidad: \$${analysis.opportunityPrice.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Línea 3: Rebote + Veredicto
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_upward, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '${(analysis.rebound * 100).toStringAsFixed(1)}%',
                    style: textTheme.bodyMedium?.copyWith(
                      color: _getReboundColor(analysis.rebound),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Text('•', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  analysis.verdict,
                  style: textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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

  Color _getReboundColor(double rebound) {
    if (rebound >= 0.05) return Colors.green.shade800;
    if (rebound >= 0.03) return Colors.green.shade700;
    return Colors.green.shade600;
  }
}
