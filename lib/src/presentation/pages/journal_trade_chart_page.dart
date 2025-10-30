import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/trade_note.dart';

class JournalTradeChartPage extends StatefulWidget {
  const JournalTradeChartPage({super.key, required this.note});

  final TradeNote note;

  @override
  State<JournalTradeChartPage> createState() => _JournalTradeChartPageState();
}

class _JournalTradeChartPageState extends State<JournalTradeChartPage> {
  late _CandleInterval _selectedInterval;
  late Future<_ChartPayload> _chartFuture;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );

  @override
  void initState() {
    super.initState();
    _selectedInterval = _CandleInterval.m15;
    _chartFuture = _loadCandles(_selectedInterval);
  }

  Future<_ChartPayload> _loadCandles(_CandleInterval interval) async {
    final symbol = _normalizeSymbol(widget.note.symbol);
    final pair = '${symbol}USDT';

    try {
      final response = await _dio.get<List<dynamic>>(
        'https://api.binance.com/api/v3/klines',
        queryParameters: <String, Object?>{
          'symbol': pair,
          'interval': interval.binanceCode,
          'limit': interval.limit,
        },
      );

      final rawData = response.data;
      if (rawData == null || rawData.isEmpty) {
        throw StateError('Binance no devolvió datos para $pair');
      }

      final candles = rawData
          .map((raw) => _IntradayCandle.fromKline(raw as List<dynamic>))
          .toList(growable: false);

      return _ChartPayload(
        symbol: symbol,
        interval: interval,
        candles: candles,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Error cargando velas intradía', error, stackTrace);
      rethrow;
    }
  }

  void _onIntervalChanged(_CandleInterval interval) {
    if (interval == _selectedInterval) return;
    setState(() {
      _selectedInterval = interval;
      _chartFuture = _loadCandles(interval);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Detalle ${widget.note.symbol}')),
    body: FutureBuilder<_ChartPayload>(
      future: _chartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ChartError(message: snapshot.error.toString());
        }

        final payload = snapshot.requireData;
        return _TradeChartView(
          payload: payload,
          note: widget.note,
          onIntervalChanged: _onIntervalChanged,
          selectedInterval: _selectedInterval,
        );
      },
    ),
  );

  String _normalizeSymbol(String raw) {
    var symbol = raw.trim().toUpperCase();
    if (symbol.contains('/')) {
      symbol = symbol.split('/').first;
    }
    if (symbol.endsWith('USDT')) {
      symbol = symbol.replaceAll('USDT', '');
    }
    return symbol;
  }
}

class _TradeChartView extends StatelessWidget {
  const _TradeChartView({
    required this.payload,
    required this.note,
    required this.selectedInterval,
    required this.onIntervalChanged,
  });

  final _ChartPayload payload;
  final TradeNote note;
  final _CandleInterval selectedInterval;
  final ValueChanged<_CandleInterval> onIntervalChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy – HH:mm');

    final entryIndex = _findClosestIndex(payload.candles, note.entryAt);
    final exitIndex = note.exitAt != null
        ? _findClosestIndex(payload.candles, note.exitAt!)
        : null;

    final entryCandle = payload.candles[entryIndex];
    final exitCandle = exitIndex != null ? payload.candles[exitIndex] : null;

    final firstTime = payload.candles.first.time;
    final lastTime = payload.candles.last.time;

    final entryLinePoints = [
      _PlotLinePoint(time: firstTime, value: note.entryPrice),
      _PlotLinePoint(time: lastTime, value: note.entryPrice),
    ];

    final exitLinePoints = note.exitPrice != null
        ? [
            _PlotLinePoint(time: firstTime, value: note.exitPrice!),
            _PlotLinePoint(time: lastTime, value: note.exitPrice!),
          ]
        : const <_PlotLinePoint>[];

    final verticalBands = <PlotBand>[
      PlotBand(
        start: entryCandle.time,
        end: entryCandle.time,
        borderColor: Colors.blueAccent.withValues(alpha: 0.4),
        dashArray: const <double>[6, 4],
      ),
    ];
    if (exitCandle != null) {
      verticalBands.add(
        PlotBand(
          start: exitCandle.time,
          end: exitCandle.time,
          borderColor: Colors.orangeAccent.withValues(alpha: 0.4),
          dashArray: const <double>[6, 4],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeadlineCard(
            note: note,
            payload: payload,
            entryText: dateFormat.format(entryCandle.time),
            exitText: exitCandle != null
                ? dateFormat.format(exitCandle.time)
                : null,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<_CandleInterval>(
              segments: _CandleInterval.values
                  .map(
                    (value) => ButtonSegment<_CandleInterval>(
                      value: value,
                      label: Text(value.label),
                    ),
                  )
                  .toList(growable: false),
              selected: <_CandleInterval>{selectedInterval},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  onIntervalChanged(selection.first);
                }
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SfCartesianChart(
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true,
                    enablePinching: true,
                  ),
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: InteractiveTooltip(
                      color: theme.colorScheme.surface,
                      textStyle: theme.textTheme.bodySmall,
                    ),
                  ),
                  primaryXAxis: DateTimeAxis(
                    intervalType: selectedInterval.axisIntervalType,
                    majorGridLines: const MajorGridLines(width: 0),
                    plotBands: verticalBands,
                    labelStyle: theme.textTheme.bodySmall,
                  ),
                  primaryYAxis: NumericAxis(
                    opposedPosition: true,
                    majorGridLines: const MajorGridLines(width: 0.5),
                    labelStyle: theme.textTheme.bodySmall,
                  ),
                  series: <CartesianSeries<dynamic, DateTime>>[
                    CandleSeries<_IntradayCandle, DateTime>(
                      dataSource: payload.candles,
                      xValueMapper: (candle, _) => candle.time,
                      lowValueMapper: (candle, _) => candle.low,
                      highValueMapper: (candle, _) => candle.high,
                      openValueMapper: (candle, _) => candle.open,
                      closeValueMapper: (candle, _) => candle.close,
                      bearColor: Colors.redAccent,
                      bullColor: Colors.greenAccent[400]!,
                      enableSolidCandles: true,
                    ),
                    LineSeries<_PlotLinePoint, DateTime>(
                      dataSource: entryLinePoints,
                      xValueMapper: (point, _) => point.time,
                      yValueMapper: (point, _) => point.value,
                      color: Colors.blueAccent.withValues(alpha: 0.6),
                      dashArray: const <double>[6, 4],
                    ),
                    if (exitLinePoints.isNotEmpty)
                      LineSeries<_PlotLinePoint, DateTime>(
                        dataSource: exitLinePoints,
                        xValueMapper: (point, _) => point.time,
                        yValueMapper: (point, _) => point.value,
                        color: Colors.orangeAccent.withValues(alpha: 0.6),
                        dashArray: const <double>[6, 4],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _LegendRow(exitAvailable: note.exitPrice != null),
        ],
      ),
    );
  }

  int _findClosestIndex(List<_IntradayCandle> candles, DateTime target) {
    final targetUtc = target.toUtc();
    var closestIndex = 0;
    var smallestDiff = double.infinity;

    for (var i = 0; i < candles.length; i++) {
      final diff = candles[i].time
          .toUtc()
          .difference(targetUtc)
          .inMinutes
          .abs()
          .toDouble();
      if (diff < smallestDiff) {
        smallestDiff = diff;
        closestIndex = i;
      }
    }

    return closestIndex;
  }
}

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({
    required this.note,
    required this.payload,
    required this.entryText,
    this.exitText,
  });

  final TradeNote note;
  final _ChartPayload payload;
  final String entryText;
  final String? exitText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${payload.symbol} / USDT',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _SummaryChip(
                  label: 'Entrada',
                  value: '\$${note.entryPrice.toStringAsFixed(2)}',
                ),
                _SummaryChip(
                  label: 'Dirección',
                  value: note.side.toUpperCase(),
                ),
                _SummaryChip(label: 'Fecha entrada', value: entryText),
                if (exitText != null)
                  _SummaryChip(label: 'Fecha salida', value: exitText!),
                _SummaryChip(
                  label: 'Resultado',
                  value: _formatResult(note),
                  highlight: note.exitPrice != null,
                ),
              ],
            ),
            if (note.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(note.notes),
            ],
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: note.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatResult(TradeNote note) {
    if (note.exitPrice == null || note.size == null) return '-';
    final diff = (note.exitPrice! - note.entryPrice) * note.size!;
    final prefix = diff >= 0 ? '+' : '-';
    return '$prefix\$${diff.abs().toStringAsFixed(2)}';
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.exitAvailable});

  final bool exitAvailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _LegendItem(color: Colors.blueAccent, label: 'Entrada'),
        if (exitAvailable)
          const _LegendItem(color: Colors.orangeAccent, label: 'Salida'),
        _LegendItem(color: theme.colorScheme.primary, label: 'Precio cierre'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    return Chip(
      backgroundColor: color,
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartError extends StatelessWidget {
  const _ChartError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            'No se pudo cargar el gráfico',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _ChartPayload {
  const _ChartPayload({
    required this.symbol,
    required this.interval,
    required this.candles,
  });

  final String symbol;
  final _CandleInterval interval;
  final List<_IntradayCandle> candles;
}

class _IntradayCandle {
  const _IntradayCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory _IntradayCandle.fromKline(List<dynamic> data) => _IntradayCandle(
    time: DateTime.fromMillisecondsSinceEpoch(
      (data[0] as num).toInt(),
      isUtc: true,
    ),
    open: double.parse(data[1].toString()),
    high: double.parse(data[2].toString()),
    low: double.parse(data[3].toString()),
    close: double.parse(data[4].toString()),
    volume: double.parse(data[5].toString()),
  );

  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
}

class _PlotLinePoint {
  const _PlotLinePoint({required this.time, required this.value});

  final DateTime time;
  final double value;
}

enum _CandleInterval { m15, h1, h4 }

extension on _CandleInterval {
  String get binanceCode {
    switch (this) {
      case _CandleInterval.m15:
        return '15m';
      case _CandleInterval.h1:
        return '1h';
      case _CandleInterval.h4:
        return '4h';
    }
  }

  int get limit {
    switch (this) {
      case _CandleInterval.m15:
        return 200;
      case _CandleInterval.h1:
        return 300;
      case _CandleInterval.h4:
        return 300;
    }
  }

  String get label {
    switch (this) {
      case _CandleInterval.m15:
        return '15m';
      case _CandleInterval.h1:
        return '1h';
      case _CandleInterval.h4:
        return '4h';
    }
  }

  DateTimeIntervalType get axisIntervalType {
    switch (this) {
      case _CandleInterval.m15:
        return DateTimeIntervalType.hours;
      case _CandleInterval.h1:
        return DateTimeIntervalType.hours;
      case _CandleInterval.h4:
        return DateTimeIntervalType.hours;
    }
  }
}
