import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trade_note.dart';
import '../bloc/journal/journal_bloc.dart';
import '../bloc/journal/journal_event.dart';
import '../bloc/journal/journal_state.dart';
import '../theme/app_colors.dart';
import '../widgets/journal_entry_form.dart';
import 'journal_trade_chart_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  TradeFilter _selectedFilter = TradeFilter.all;
  static const String _userId = 'richard'; // Usuario configurado para el backend

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

  List<TradeNote> _getFilteredNotes(List<TradeNote> notes) {
    switch (_selectedFilter) {
      case TradeFilter.long:
        return notes.where((note) => note.side == 'buy').toList();
      case TradeFilter.short:
        return notes.where((note) => note.side == 'sell').toList();
      case TradeFilter.all:
        return notes;
    }
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
      final filteredNotes = _getFilteredNotes(state.notes);

      Widget body;

      if (state.isLoading && state.notes.isEmpty) {
        body = const Center(child: CircularProgressIndicator());
      } else if (state.notes.isEmpty) {
        body = RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
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
                        backgroundColor: isDark
                          ? AppColors.darkAccentPrimary
                          : AppColors.lightAccentPrimary,
                        foregroundColor: Colors.white,
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
                    _JournalHeader(
                      notes: filteredNotes,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _FilterSection(
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = filter);
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (filteredNotes.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list_off,
                            size: 48,
                            color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay operaciones ${_getFilterLabel()}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
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

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: body,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: state.isSubmitting ? null : _openCreateModal,
          icon: const Icon(Icons.add),
          label: const Text('Nueva operación'),
        ),
      );
    },
  );

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case TradeFilter.long:
        return 'BUY';
      case TradeFilter.short:
        return 'SELL';
      case TradeFilter.all:
        return '';
    }
  }

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

enum TradeFilter { all, long, short }

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({
    required this.notes,
    required this.isDark,
  });

  final List<TradeNote> notes;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _StatCard(
        label: 'Total Trades',
        value: notes.length.toString(),
        icon: Icons.swap_horiz,
        color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
        isDark: isDark,
        isLarge: true,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.isLarge = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool isLarge;

  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(isLarge ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: isLarge ? 20 : 16,
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
                  style: TextStyle(
                    fontSize: isLarge ? 12 : 10,
                    color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: color,
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

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.isDark,
  });

  final TradeFilter selectedFilter;
  final ValueChanged<TradeFilter> onFilterChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TradeFilter.values.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getFilterLabel(filter)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) onFilterChanged(filter);
                      },
                      backgroundColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                      selectedColor: isDark
                        ? AppColors.darkAccentPrimary.withValues(alpha: 0.3)
                        : AppColors.lightAccentPrimary.withValues(alpha: 0.2),
                      checkmarkColor: isDark
                        ? AppColors.darkAccentPrimary
                        : AppColors.lightAccentPrimary,
                      labelStyle: TextStyle(
                        color: isSelected
                          ? (isDark
                            ? AppColors.darkAccentPrimary
                            : AppColors.lightAccentPrimary)
                          : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                          ? (isDark
                            ? AppColors.darkAccentPrimary
                            : AppColors.lightAccentPrimary)
                          : (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );

  String _getFilterLabel(TradeFilter filter) {
    switch (filter) {
      case TradeFilter.all:
        return 'TODAS';
      case TradeFilter.long:
        return 'BUY';
      case TradeFilter.short:
        return 'SELL';
    }
  }
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

    final isProfit = note.exitPrice! >= note.entryPrice;
    return isProfit
      ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
      : (isDark ? AppColors.darkBearish : AppColors.lightBearish);
  }

  String _calculatePnL() {
    if (note.exitPrice == null || note.size == null) return '-';
    final diff = (note.exitPrice! - note.entryPrice) * note.size!;
    final prefix = diff >= 0 ? '+' : '';
    return '$prefix\$${diff.toStringAsFixed(2)}';
  }

  double _calculateROI() {
    if (note.exitPrice == null || note.size == null) return 0;
    final invested = note.entryPrice * note.size!;
    final profit = (note.exitPrice! - note.entryPrice) * note.size!;
    return (profit / invested) * 100;
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
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getSideColor(),
                              letterSpacing: 0.5,
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
                            const Text('Editar'),
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
                            const Text('Eliminar'),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Entry: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              '\$${note.entryPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              ),
                            ),
                            if (note.size != null) ...[
                              Text(
                                ' • ${note.size!.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 13,
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
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Exit: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                ),
                              ),
                              Text(
                                '\$${note.exitPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${_calculatePnL()}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _getPnLColor(),
                                ),
                              ),
                              Text(
                                ' (${_calculateROI().toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _getPnLColor(),
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
