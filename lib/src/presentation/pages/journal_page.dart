import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trade_note.dart';
import '../bloc/journal/journal_bloc.dart';
import '../bloc/journal/journal_event.dart';
import '../bloc/journal/journal_state.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../widgets/journal_entry_form.dart';
import 'journal_trade_chart_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  static const String _userId = 'richard'; // Usuario configurado para el backend
  DateTime _selectedMonth = DateTime.now();

  Future<void> _onRefresh() async {
    context.read<JournalBloc>().add(const LoadJournalNotes(userId: _userId));
  }

  Future<void> _openCreateModal() async {
    final result = await showModalBottomSheet<TradeNoteFormResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => const TradeNoteFormSheet(),
    );

    if (!mounted || result == null) return;

    context.read<JournalBloc>().add(
      AddJournalNote(
        symbol: result.symbol,
        entryPrice: result.entryPrice,
        entryAt: result.entryAt,
        side: result.side,
        exitPrice: result.exitPrice,
        exitAt: result.exitAt,
        size: result.size,
        notes: result.notes,
        tags: result.tags,
        userId: _userId,
      ),
    );
  }
  
  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year, 
        _selectedMonth.month + offset,
      );
    });
  }

  List<TradeNote> _filterNotesByMonth(List<TradeNote> allNotes) {
    final start = DateTime(_selectedMonth.year, _selectedMonth.month);
    final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    
    // Sort by exit date if closed, or entry date if open, but prioritizing relevance to selected month
    return allNotes.where((note) {
      // If we are looking at past history, we primarily care about trades CLOSED in that month
      // logic: "ese historial tiene que tomar es profit, y ese dia que se cierre es que tome el profit"
      // So detailed list should show trades that affect PnL of that month (Exit Date in Month)
      // OR active trades if we are in current month? 
      // Simplified: Show trades that have Exit Date in this month.
      // If 'Current Month', also show open trades (Entry Date <= Today && Exit Date == null or Exit Date > Today)?
      // To simulate "History", usually we list Closed Trades for that period.
      // But user might want to see Open trades in "Current Month".
      
      final isCurrentMonth = start.month == DateTime.now().month && start.year == DateTime.now().year;
      
      if (note.exitAt != null) {
         // Closed trade: does it belong to this month's PnL?
         return note.exitAt!.isAfter(start) && note.exitAt!.isBefore(end);
      } else {
         // Open trade: only show if selecting Current Month 
         return isCurrentMonth;
      }
    }).toList()
      ..sort((a, b) {
        // Sort closed trades by exit date, open trades by entry date
        final dateA = a.exitAt ?? a.entryAt;
        final dateB = b.exitAt ?? b.entryAt;
        return dateB.compareTo(dateA);
      });
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<JournalBloc, JournalState>(
    listenWhen: (previous, current) =>
        previous.errorMessage != current.errorMessage &&
        current.errorMessage != null,
    listener: (context, state) {
      final message = state.errorMessage;
      if (message == null) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    },
    builder: (context, state) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final allNotes = state.notes;
      final filteredNotes = _filterNotesByMonth(allNotes);

      Widget body;

      if (state.isLoading && allNotes.isEmpty) {
        body = const Center(child: CircularProgressIndicator());
      } else if (allNotes.isEmpty) { // Keep empty state logic simple but maybe check filtered? No, if global empty, allow create.
         // ... (existing empty state logic same as before, truncated for brevity, I will reuse existing if possible or re-declare)
         // Actually, I need to replace the entire build method or chunks. Let's rewrite the body logic.
         // Re-using existing empty state for 'global' emptiness.
         
         if (filteredNotes.isEmpty && state.notes.isNotEmpty) {
            // Special empty state for filter?
         }
         
         // Reuse existing Empty State from lines 76-140 if no notes globally
         body = RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
               SizedBox(height: MediaQuery.of(context).size.height * 0.2),
               // ... same empty container ...
                Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 72,
                      color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trading Journal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registra tus operaciones para analizar tu rendimiento y mejorar tus estrategias',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: state.isSubmitting ? null : _openCreateModal,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Primera operación'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        body = RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Month Selector Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _changeMonth(-1),
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          Text(
                            DateFormat('MMMM yyyy', 'es').format(_selectedMonth).toUpperCase(),
                            style: AppTextStyles.h4.copyWith(
                               color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _changeMonth(1),
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _JournalHeader(
                      notes: filteredNotes, // Pass filtered notes for stats
                      isDark: isDark,
                      selectedDate: _selectedMonth,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (filteredNotes.isEmpty)
                SliverFillRemaining(
                   child: Center(
                     child: Text(
                       'No hay operaciones en este mes',
                       style: AppTextStyles.bodyLarge.copyWith(
                         color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                       ),
                     ),
                   ),
                )
              else 
                SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: filteredNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ProfessionalTradeCard(
                    note: filteredNotes[index],
                    onOpenDetail: () => _openDetail(filteredNotes[index]),
                    onEdit: () => _openEdit(filteredNotes[index]),
                    onDelete: () => _confirmDelete(filteredNotes[index]),
                    isDark: isDark,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      }

      final fabColor = isDark
        ? AppColors.darkAlert
        : AppColors.lightAlert;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: state.isSubmitting ? null : _openCreateModal,
          backgroundColor: fabColor,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add),
        ),
      );
    },
  );

  void _openDetail(TradeNote note) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JournalTradeChartPage(note: note),
      ),
    );
  }

  Future<void> _openEdit(TradeNote note) async {
    final result = await showModalBottomSheet<TradeNoteFormResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => TradeNoteFormSheet(initialNote: note),
    );

    if (!mounted || result == null) return;

    context.read<JournalBloc>().add(
      UpdateJournalNote(
        id: note.id,
        symbol: result.symbol,
        side: result.side,
        entryPrice: result.entryPrice,
        entryAt: result.entryAt,
        exitPrice: result.exitPrice,
        exitAt: result.exitAt,
        size: result.size,
        notes: result.notes,
        tags: result.tags,
        userId: note.userId,
      ),
    );
  }

  Future<void> _confirmDelete(TradeNote note) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar operación'),
            content: Text(
              '¿Eliminar la operación en ${note.symbol}? Esta acción es irreversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !shouldDelete) return;

    context.read<JournalBloc>().add(
      DeleteJournalNote(id: note.id, userId: note.userId),
    );
  }
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({
    required this.notes,
    required this.isDark,
    required this.selectedDate,
  });

  final List<TradeNote> notes;
  final bool isDark;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    // Parent already filtered 'notes' to be specific to this month's view
    // Calculate PnL from these filtered notes
    final monthlyPnL = _calculateMonthlyPnL();
    final pnlColor = monthlyPnL >= 0 
        ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
        : (isDark ? AppColors.darkBearish : AppColors.lightBearish);

    final isCurrentMonth = selectedDate.month == DateTime.now().month && selectedDate.year == DateTime.now().year;
    final label = isCurrentMonth ? 'Profit (Mes)' : 'Profit';

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Trades',
                value: notes.length.toString(),
                icon: Icons.swap_horiz,
                color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
                isDark: isDark,
              ),
            ),
             // Separator vertical line
             Container(
               height: 40,
               width: 1,
               margin: const EdgeInsets.symmetric(horizontal: 16),
               color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
             ),
             Expanded(
              child: _StatCard(
                label: label,
                value: '\$${NumberFormat('#,##0.00').format(monthlyPnL)}',
                icon: Icons.attach_money,
                color: pnlColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
      );
  }

  double _calculateMonthlyPnL() {
    double totalPnL = 0;
    
    // Notes are already filtered by parent for this month/period
    for (final note in notes) {
      if (note.exitPrice != null && note.exitAt != null) {
        final size = note.size ?? 0;
        final entryPrice = note.entryPrice;
        final exitPrice = note.exitPrice!;
        
        if (entryPrice <= 0) continue;

        final quantity = size / entryPrice;
        
        double tradePnL = 0;
        if (note.side.toLowerCase() == 'sell') {
           tradePnL = (entryPrice - exitPrice) * quantity;
        } else {
           tradePnL = (exitPrice - entryPrice) * quantity;
        }

        totalPnL += tradePnL;
      }
    }
    return totalPnL;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(8), // Fixed compact padding
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 14, // Fixed compact icon size
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.h4.copyWith(
                    fontSize: 16, // Fixed compact value size
                    color: color,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
}

class _ProfessionalTradeCard extends StatelessWidget {
  const _ProfessionalTradeCard({
    required this.note,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
    required this.isDark,
  });

  final TradeNote note;
  final VoidCallback onOpenDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDark;

  static final DateFormat _dateFormat = DateFormat('dd MMM, HH:mm');
  static final NumberFormat _currencyFormatter = NumberFormat('#,##0.00');
  static final NumberFormat _sizeFormatter = NumberFormat('#,##0.##');

  Color _getSideColor() {
    if (note.side == 'buy') {
      return isDark ? AppColors.darkBullish : AppColors.lightBullish;
    } else {
      return isDark ? AppColors.darkBearish : AppColors.lightBearish;
    }
  }

  Color _getPnLColor() {
    if (note.exitPrice == null) {
      return isDark
      ? AppColors.darkTextSecondary
      : AppColors.lightTextSecondary;
    }

    return _isProfitableTrade()
      ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
      : (isDark ? AppColors.darkBearish : AppColors.lightBearish);
  }

  String _calculatePnL() {
    final pnlValue = _resolvePnLValue();
    if (pnlValue == null) return '-';
    final prefix = pnlValue >= 0 ? '+' : '-';
    final formatted = _currencyFormatter.format(pnlValue.abs());
    return '$prefix\$$formatted';
  }

  double _calculateROI() {
    final pnlValue = _resolvePnLValue();
    if (note.exitPrice == null || pnlValue == null) return 0;

    final invested = _investedAmount();
    if (invested <= 0) return 0;

    return (pnlValue / invested) * 100;
  }

  double? _resolvePnLValue() {
    if (note.exitPrice == null) return null;
    final quantity = _positionQuantity();
    final priceDiff = note.exitPrice! - note.entryPrice;
    return priceDiff * quantity;
  }

  double _positionQuantity() {
    final size = note.size;
    if (size == null || size <= 0) return 1;
    if (note.entryPrice <= 0) {
      return size;
    }
    return size / note.entryPrice;
  }

  double _investedAmount() {
    final size = note.size;
    if (size != null && size > 0) {
      return size;
    }
    return note.entryPrice > 0 ? note.entryPrice : 0;
  }

  String _buildDurationLabel() {
    final end = note.exitAt ?? DateTime.now().toUtc();
    final duration = end.difference(note.entryAt);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      if (hours > 0) return '$days d $hours h';
      return '$days d';
    }
    if (duration.inHours > 0) {
      if (minutes > 0) return '${duration.inHours} h $minutes min';
      return '${duration.inHours} h';
    }
    return '${duration.inMinutes} min';
  }

  String _formatPositionSize(double value) {
    if (value.abs() >= 1) {
      return _sizeFormatter.format(value);
    }
    final fixed = value.toStringAsFixed(4);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  bool _isProfitableTrade() {
    if (note.exitPrice == null) return false;
    if (note.side == 'sell') {
      return note.exitPrice! <= note.entryPrice;
    }
    return note.exitPrice! >= note.entryPrice;
  }

  @override
  Widget build(BuildContext context) => InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onOpenDetail,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con símbolo, side y menú
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          note.symbol,
                          style: AppTextStyles.h4.copyWith(
                            color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSideColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getSideColor().withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            note.side == 'buy' ? 'BUY' : 'SELL',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getSideColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_TradeCardAction>(
                    tooltip: 'Acciones',
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    ),
                    onSelected: (action) {
                      switch (action) {
                        case _TradeCardAction.edit:
                          onEdit();
                          break;
                        case _TradeCardAction.delete:
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<_TradeCardAction>(
                        value: _TradeCardAction.edit,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Editar',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<_TradeCardAction>(
                        value: _TradeCardAction.delete,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: isDark
                                ? AppColors.darkBearish
                                : AppColors.lightBearish,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Eliminar',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkBearish
                                    : AppColors.lightBearish,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Timeline: Entry
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getSideColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (note.exitPrice != null) ...[
                        Container(
                          width: 2,
                          height: 40,
                          color: _getSideColor().withValues(alpha: 0.3),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dateFormat.format(note.entryAt.toLocal()),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Entry: ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              '\$${note.entryPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.priceMedium.copyWith(
                                color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              ),
                            ),
                            if (note.size != null) ...[
                              Text(
                                ' • ${_formatPositionSize(note.size!)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Timeline: Exit (si existe)
              if (note.exitPrice != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPnLColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.exitAt != null
                              ? _dateFormat.format(note.exitAt!.toLocal())
                              : 'Salida',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Exit: ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                ),
                              ),
                              Text(
                                '\$${note.exitPrice!.toStringAsFixed(2)}',
                                style: AppTextStyles.priceMedium.copyWith(
                                  color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '• ${_calculatePnL()} (${_calculateROI().toStringAsFixed(1)}%)',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getPnLColor(),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    note.exitAt == null
                      ? 'Abierta hace ${_buildDurationLabel()}'
                      : 'Duración ${_buildDurationLabel()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),

              // Tags y notas
              if (note.tags.isNotEmpty || note.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                      ? AppColors.darkSurface.withValues(alpha: 0.5)
                      : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: note.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                ? AppColors.darkAccentPrimary.withValues(alpha: 0.2)
                                : AppColors.lightAccentPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                  ? AppColors.darkAccentPrimary
                                  : AppColors.lightAccentPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )).toList(),
                        ),
                        if (note.notes.isNotEmpty) const SizedBox(height: 8),
                      ],
                      if (note.notes.isNotEmpty)
                        Text(
                          note.notes,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
}

enum _TradeCardAction { edit, delete }
