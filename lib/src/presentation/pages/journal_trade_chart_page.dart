import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/entities/trade_note.dart';
import '../theme/app_colors.dart';

class JournalTradeChartPage extends StatefulWidget {
  const JournalTradeChartPage({super.key, required this.note});

  final TradeNote note;

  @override
  State<JournalTradeChartPage> createState() => _JournalTradeChartPageState();
}

class _JournalTradeChartPageState extends State<JournalTradeChartPage> {
  late final WebViewController _controller;
  String _selectedInterval = '60'; // 1 hour in minutes
  final NumberFormat _currencyFormatter = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadRequest(Uri.parse(_buildTradingViewUrl()));
  }

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

  String _getExchangeForSymbol(String symbol) {
    const exchangeMap = {
      // Bybit
      'MNT': 'BYBIT',
      'BBSOL': 'BYBIT',

      // Kucoin
      'KCS': 'KUCOIN',

      // Bitget
      'BGB': 'BITGET',
    };

    return exchangeMap[_normalizeSymbol(symbol)] ?? 'BINANCE';
  }

  String _buildTradingViewUrl() {
    final normalized = _normalizeSymbol(widget.note.symbol);
    final exchange = _getExchangeForSymbol(normalized);
    final theme = Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light';

    return 'https://s.tradingview.com/widgetembed/?'
        'symbol=$exchange:${normalized}USDT&'
        'interval=$_selectedInterval&'
        'hideideas=1&'
        'theme=$theme&'
        'style=1&'
        'locale=en&'
        'toolbar_bg=rgba(255,255,255,0)&'
        'allow_symbol_change=0&'
        'save_image=0&'
        'hide_top_toolbar=0&'
        'hide_legend=0&'
        'studies_overrides={}&'
        'overrides={}&'
        'enabled_features=[]&'
        'disabled_features=["use_localstorage_for_settings"]&'
        'withdateranges=1&'
        'hide_side_toolbar=0';
  }

  void _changeInterval(String interval) {
    setState(() {
      _selectedInterval = interval;
      _controller.loadRequest(Uri.parse(_buildTradingViewUrl()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.note.side == 'buy'
                    ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
                        .withValues(alpha: 0.2)
                    : (isDark ? AppColors.darkBearish : AppColors.lightBearish)
                        .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                widget.note.side == 'buy' ? Icons.trending_up : Icons.trending_down,
                color: widget.note.side == 'buy'
                    ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
                    : (isDark ? AppColors.darkBearish : AppColors.lightBearish),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.note.symbol} Trade',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.note.side == 'buy' ? 'LONG' : 'SHORT',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.note.side == 'buy'
                          ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
                          : (isDark ? AppColors.darkBearish : AppColors.lightBearish),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  'Entry',
                  '\$${widget.note.entryPrice.toStringAsFixed(2)}',
                  isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                  isDark,
                ),
                if (widget.note.exitPrice != null)
                  _buildMetric(
                    'Exit',
                    '\$${widget.note.exitPrice!.toStringAsFixed(2)}',
                    isDark ? AppColors.darkAlert : AppColors.lightAlert,
                    isDark,
                  ),
                if (widget.note.exitPrice != null)
                  _buildMetric(
                    'P&L',
                    _calculatePnL(),
                    _isProfitable()
                        ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
                        : (isDark ? AppColors.darkBearish : AppColors.lightBearish),
                    isDark,
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                _buildTimeframeButton('15m', '15', isDark),
                _buildTimeframeButton('1H', '60', isDark),
                _buildTimeframeButton('4H', '240', isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    Positioned(
                      right: 16,
                      top: 60,
                      bottom: 80,
                      child: _buildPriceMarkers(isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color, bool isDark) => Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );

  Widget _buildTimeframeButton(String label, String interval, bool isDark) {
    final isSelected = _selectedInterval == interval;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeInterval(interval),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _calculatePnL() {
    final pnlValue = _resolvePnLValue();
    if (pnlValue == null) return '-';
    final prefix = pnlValue >= 0 ? '+' : '-';
    final formatted = _currencyFormatter.format(pnlValue.abs());
    return '$prefix\$$formatted';
  }

  bool _isProfitable() {
    if (widget.note.exitPrice == null) return false;
    if (widget.note.side == 'sell') {
      return widget.note.exitPrice! <= widget.note.entryPrice;
    }
    return widget.note.exitPrice! >= widget.note.entryPrice;
  }

  double? _resolvePnLValue() {
    if (widget.note.exitPrice == null) return null;
    final quantity = _positionQuantity();
    final priceDiff = widget.note.exitPrice! - widget.note.entryPrice;
    return priceDiff * quantity;
  }

  double _positionQuantity() {
    final size = widget.note.size;
    if (size == null || size <= 0) return 1;
    if (widget.note.entryPrice <= 0) return size;
    return size / widget.note.entryPrice;
  }

  Widget _buildPriceMarkers(bool isDark) {
    final entryColor = isDark ? AppColors.darkBullish : AppColors.lightBullish;
    final exitColor = isDark ? AppColors.darkBearish : AppColors.lightBearish;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPriceMarker('ENTRY', widget.note.entryPrice, entryColor),
        if (widget.note.exitPrice != null) ...[
          const SizedBox(height: 12),
          _buildPriceMarker('EXIT', widget.note.exitPrice!, exitColor),
        ],
      ],
    );
  }

  Widget _buildPriceMarker(String label, double price, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}
