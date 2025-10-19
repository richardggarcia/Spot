import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/di/service_locator.dart';
import '../../domain/entities/daily_analysis.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/ports/price_data_port.dart';
import '../../domain/services/historical_analysis_service.dart';
import '../widgets/monthly_panorama_widget.dart';
import '../widgets/weekly_summary_widget.dart';

class HistoricalViewPage extends StatefulWidget {

  const HistoricalViewPage({
    super.key,
    required this.symbol,
    required this.cryptoName,
  });
  final String symbol;
  final String cryptoName;

  @override
  State<HistoricalViewPage> createState() => _HistoricalViewPageState();
}

class _HistoricalViewPageState extends State<HistoricalViewPage> with TickerProviderStateMixin {
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
      final candles = await _priceAdapter.getHistoricalData(widget.symbol, days: 95);
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
          _error = '⚠️ Datos históricos no disponibles\n\n'
              '${widget.cryptoName} (${widget.symbol}) no tiene datos históricos en nuestras fuentes:\n\n'
              '• No disponible en Binance\n'
              '• CoinGecko requiere API key premium\n\n'
              'Puedes ver el precio actual y las métricas diarias en la pantalla principal.';
        } else if (e.toString().contains('404') || e.toString().contains('Invalid symbol') || e.toString().contains('No data')) {
          _error = 'No hay datos históricos disponibles para ${widget.cryptoName} (${widget.symbol}).\n\nAlgunas criptomonedas no tienen suficiente historial en las fuentes de datos.';
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
  Widget build(BuildContext context) => Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadHistoricalData,
        child: _buildBody(),
      ),
    );

  Widget _buildBody() {
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
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
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
      );
    }
    if (_reports.isEmpty) {
      return const Center(child: Text('No hay datos disponibles.'));
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Text('${widget.cryptoName} - Histórico'),
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
            bottom: TabBar(
              controller: _tabController,
              tabs: _reports.map((r) => Tab(text: r.monthName.toUpperCase())).toList(),
            ),
          ),
        ],
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
          final isWeekend = day.weekday == DateTime.sunday || day.weekday == DateTime.saturday;
          return Center(
            child: Text(
              text.substring(0, 2), // Mostrar solo las dos primeras letras
              style: TextStyle(
                color: isWeekend ? Colors.red : Colors.black87,
                fontSize: 12, // Tamaño de fuente más pequeño
              ),
            ),
          );
        },
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade200,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue.shade500,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
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
          Text(dateStr, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (analysis.verdict.isNotEmpty)
            Text(
              '"${analysis.verdict}"',
              style: textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MetricTile(label: 'Caída Profunda', value: analysis.formattedDeepDrop, color: Colors.red),
              _MetricTile(label: 'Rebote', value: analysis.formattedRebound, color: Colors.green),
            ],
          ),
          const SizedBox(height: 16),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MetricTile(label: 'Precio Oportunidad', value: '\$${analysis.opportunityPrice.toStringAsFixed(2)}', color: Colors.blueGrey),
              _MetricTile(label: 'Cierre Neto', value: analysis.formattedNetChange, color: analysis.netChange >= 0 ? Colors.green : Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {

  const _MetricTile({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
}
