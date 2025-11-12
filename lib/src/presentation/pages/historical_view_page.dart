import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/di/service_locator.dart';
import '../../domain/entities/daily_analysis.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/notification_data.dart';
import '../../domain/ports/price_data_port.dart';
import '../../domain/services/historical_analysis_service.dart';
import '../theme/app_colors.dart';
import '../widgets/monthly_panorama_widget.dart';
import '../widgets/weekly_summary_widget.dart';

class HistoricalViewPage extends StatefulWidget {
  const HistoricalViewPage({
    super.key,
    required this.symbol,
    required this.cryptoName,
    this.alertInsight,
  });
  final String symbol;
  final String cryptoName;
  final NotificationData? alertInsight;

  @override
  State<HistoricalViewPage> createState() => _HistoricalViewPageState();
}

class _HistoricalViewPageState extends State<HistoricalViewPage>
    with TickerProviderStateMixin {
  late final PriceDataPort _priceAdapter;
  final _analysisService = HistoricalAnalysisService();

  List<MonthlyReport> _reports = [];
  bool _isLoading = true;
  String? _error;
  TabController? _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _priceAdapter = ServiceLocator.get<PriceDataPort>();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final candles = await _priceAdapter.getHistoricalData(
        widget.symbol,
        days: 95,
      );
      if (!mounted) return;

      final reports = _analysisService.generateReportsForLastMonths(
        symbol: widget.symbol,
        cryptoName: widget.cryptoName,
        candles: candles,
      );

      if (reports.isEmpty) {
        throw Exception('No se pudieron generar reportes históricos.');
      }

      _tabController = TabController(length: reports.length, vsync: this);
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) {
          _updateFocusedDay();
        }
      });

      setState(() {
        _reports = reports;
        _focusedDay = _reports.first.allDays.last.date;
        _selectedDay = _focusedDay;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Lista de monedas sin soporte histórico
        final unsupportedCoins = ['MNT', 'KCS', 'BGB', 'RON'];

        // Mensaje de error más amigable
        if (unsupportedCoins.contains(widget.symbol)) {
          _error =
              '⚠️ Datos históricos no disponibles\n\n'
              '${widget.cryptoName} (${widget.symbol}) no tiene datos históricos en nuestras fuentes:\n\n'
              '• No disponible en Binance\n'
              '• CoinGecko requiere API key premium\n\n'
              'Puedes ver el precio actual y las métricas diarias en la pantalla principal.';
        } else if (e.toString().contains('404') ||
            e.toString().contains('Invalid symbol') ||
            e.toString().contains('No data')) {
          _error =
              'No hay datos históricos disponibles para ${widget.cryptoName} (${widget.symbol}).\n\nAlgunas criptomonedas no tienen suficiente historial en las fuentes de datos.';
        } else {
          _error = 'Error al cargar datos históricos:\n${e.toString()}';
        }
        _isLoading = false;
      });
    }
  }

  void _updateFocusedDay() {
    final report = _reports[_tabController!.index];
    final lastDayOfMonth = DateTime(report.year, report.month + 1, 0);
    final now = DateTime.now();

    setState(() {
      if (report.month == now.month && report.year == now.year) {
        _focusedDay = now;
      } else {
        _focusedDay = lastDayOfMonth;
      }
      _selectedDay = _focusedDay;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadHistoricalData,
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? Colors.orange.shade300 : Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _loadHistoricalData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    if (_reports.isEmpty) {
      return const Center(child: Text('No hay datos disponibles.'));
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        final slivers = <Widget>[];

        if (widget.alertInsight != null &&
            widget.alertInsight!.type == NotificationType.priceAlert) {
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _AlertInsightBanner(data: widget.alertInsight!),
              ),
            ),
          );
        }

        slivers.add(
          SliverAppBar(
            title: Text('${widget.cryptoName} - Histórico'),
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
            bottom: TabBar(
              controller: _tabController,
              tabs: _reports
                  .map((r) => Tab(text: r.monthName.toUpperCase()))
                  .toList(),
            ),
          ),
        );

        return slivers;
      },
      body: TabBarView(
        controller: _tabController,
        children: _reports.map(_buildMonthView).toList(),
      ),
    );
  }

  Widget _buildMonthView(MonthlyReport report) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _buildCalendar(report),
        const SizedBox(height: 24),
        MonthlyPanoramaWidget(report: report),
        const SizedBox(height: 16),
        WeeklySummaryWidget(weeks: report.weeks),
      ],
    ),
  );

  Widget _buildCalendar(MonthlyReport report) => TableCalendar(
    locale: 'es_ES',
    firstDay: DateTime.utc(report.year, report.month),
    lastDay: DateTime.utc(report.year, report.month + 1, 0),
    focusedDay: _focusedDay,
    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
    startingDayOfWeek: StartingDayOfWeek.monday,
    eventLoader: (day) {
      final analysis = report.getAnalysisForDay(day);
      // Mostrar punto si hay alerta (ahora definida por caída >= 3%)
      if (analysis != null && analysis.hasAlert) {
        return ['event'];
      }
      return [];
    },
    onDaySelected: (selectedDay, focusedDay) {
      final analysis = report.getAnalysisForDay(selectedDay);
      if (analysis != null) {
        _showDayDetails(context, analysis);
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      }
    },
    calendarBuilders: CalendarBuilders<String>(
      dowBuilder: (context, day) {
        final text = DateFormat.E('es_ES').format(day);
        final isWeekend =
            day.weekday == DateTime.sunday || day.weekday == DateTime.saturday;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: Text(
            text.substring(0, 2), // Mostrar solo las dos primeras letras
            style: TextStyle(
              color: isWeekend
                  ? (isDark ? Colors.red.shade300 : Colors.red)
                  : (isDark ? Colors.white70 : Colors.black87),
              fontSize: 12,
            ),
          ),
        );
      },
    ),
    calendarStyle: CalendarStyle(
      todayDecoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade700
            : Colors.blue.shade200,
        shape: BoxShape.circle,
      ),
      selectedDecoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade600
            : Colors.blue.shade500,
        shape: BoxShape.circle,
      ),
      markerDecoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.red.shade400
            : Colors.red,
        shape: BoxShape.circle,
      ),
      // Colores de texto del calendario
      defaultTextStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
      weekendTextStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.red.shade300
            : Colors.red,
      ),
      outsideTextStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade600
            : Colors.grey.shade400,
      ),
    ),
    headerStyle: const HeaderStyle(
      titleCentered: true,
      formatButtonVisible: false,
    ),
  );

  void _showDayDetails(BuildContext context, DailyAnalysis analysis) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _DayCard(analysis: analysis),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.analysis});
  final DailyAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateStr = DateFormat.yMMMMEEEEd('es_ES').format(analysis.date);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateStr,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (analysis.verdict.isNotEmpty)
            Text(
              '"${analysis.verdict}"',
              style: textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MetricTile(
                label: 'Caída Profunda',
                value: analysis.formattedDeepDrop,
                color: Colors.red,
              ),
              _MetricTile(
                label: 'Rebote',
                value: analysis.formattedRebound,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MetricTile(
                label: 'Precio Oportunidad',
                value: '\$${analysis.opportunityPrice.toStringAsFixed(2)}',
                color: Colors.blueGrey,
              ),
              _MetricTile(
                label: 'Cierre Neto',
                value: analysis.formattedNetChange,
                color: analysis.netChange >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

class _AlertInsightBanner extends StatelessWidget {
  const _AlertInsightBanner({required this.data});

  final NotificationData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dropLabel = _formatPercentage(data.dropPercent);
    final confidenceLabel = data.confidence != null
        ? '${data.confidence!.toStringAsFixed(0)}% confianza'
        : null;
    final timeframeLabel = data.timeframe;
    final actionLabel = data.analysisType ?? 'Análisis IA';
    final priceTargetsText = _formatPriceTargets(data.priceTargets);

    final chips = <Widget>[];
    if (dropLabel != null) {
      chips.add(
        _InsightChip(
          icon: Icons.trending_down,
          label: 'Caída $dropLabel',
          background: isDark
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.red.shade50,
          foreground: isDark ? Colors.red.shade200 : Colors.red.shade700,
        ),
      );
    }
    if (confidenceLabel != null) {
      chips.add(
        _InsightChip(
          icon: Icons.verified,
          label: confidenceLabel,
          background: isDark
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.green.shade50,
          foreground: isDark ? Colors.green.shade200 : Colors.green.shade700,
        ),
      );
    }
    if (timeframeLabel != null && timeframeLabel.isNotEmpty) {
      chips.add(
        _InsightChip(
          icon: Icons.timer,
          label: timeframeLabel,
          background: isDark
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.blue.shade50,
          foreground: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
        ),
      );
    }
    if (data.aiEngine != null && data.aiEngine!.isNotEmpty) {
      chips.add(
        _InsightChip(
          icon: Icons.memory,
          label: data.aiEngine!,
          background: isDark
              ? Colors.purple.withValues(alpha: 0.2)
              : Colors.purple.shade50,
          foreground: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
        ),
      );
    }

    return Card(
      elevation: 3,
      color: isDark ? Colors.blueGrey.shade900 : Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_graph,
                  color: isDark ? Colors.lightBlueAccent : Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resumen IA en tiempo real',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (data.analysisSummary != null &&
                data.analysisSummary!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  data.analysisSummary!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(actionLabel, style: theme.textTheme.bodyMedium),
              ),
            if (chips.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(spacing: 8, runSpacing: 8, children: chips),
              ),
            if ((data.causeSummary ?? data.cause)?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _InsightSection(
                  icon: Icons.warning_amber_rounded,
                  title: 'Causa probable',
                  content: data.causeSummary ?? data.cause!,
                ),
              ),
            if (data.strategySummary != null &&
                data.strategySummary!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _InsightSection(
                  icon: Icons.campaign,
                  title: 'Estrategia sugerida',
                  content: data.strategySummary!,
                ),
              )
            else if (priceTargetsText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _InsightSection(
                  icon: Icons.campaign,
                  title: 'Estrategia sugerida',
                  content: priceTargetsText,
                ),
              ),
            if (data.hasNews)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _InsightSection(
                  icon: Icons.newspaper,
                  title: 'Contexto de noticias',
                  content:
                      data.primaryNews ??
                      'Revisa los eventos clave relacionados.',
                ),
              ),
            if (data.newsItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: data.newsItems
                      .take(2)
                      .map((item) => _NewsItemTile(item: item))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String? _formatPercentage(double? value) {
    if (value == null) return null;
    final abs = value.abs();
    final formatted = abs.toStringAsFixed(abs >= 10 ? 1 : 2);
    final prefix = value >= 0 ? '+' : '-';
    return '$prefix$formatted%';
  }

  static String? _formatPriceTargets(Map<String, dynamic>? targets) {
    if (targets == null || targets.isEmpty) return null;

    final support =
        targets['support'] ?? targets['entry'] ?? targets['buyZone'];
    final resistance =
        targets['resistance'] ?? targets['takeProfit'] ?? targets['exit'];

    final segments = <String>[];
    if (support is String && support.isNotEmpty) {
      segments.add('Entrada $support');
    }
    if (resistance is String && resistance.isNotEmpty) {
      segments.add('Salida $resistance');
    }

    if (segments.isEmpty) {
      return null;
    }
    return segments.join(' • ');
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: foreground),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ],
    ),
  );
}

class _InsightSection extends StatelessWidget {
  const _InsightSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(content, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _NewsItemTile extends StatelessWidget {
  const _NewsItemTile({required this.item});

  final NotificationNewsItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 8,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.title != null)
                  Text(
                    item.title!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (item.summary != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.summary!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                if (item.source != null || item.publishedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [
                        if (item.source != null) item.source,
                        if (item.publishedAt != null) item.publishedAt,
                      ].whereType<String>().join(' • '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
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
