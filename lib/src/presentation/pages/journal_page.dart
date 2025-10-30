import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trade_note.dart';
import '../bloc/journal/journal_bloc.dart';
import '../bloc/journal/journal_event.dart';
import '../bloc/journal/journal_state.dart';
import '../widgets/journal_entry_form.dart';
import 'journal_trade_chart_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  Future<void> _onRefresh() async {
    context.read<JournalBloc>().add(const LoadJournalNotes());
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
      ),
    );
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
      Widget body;

      if (state.isLoading && state.notes.isEmpty) {
        body = const Center(child: CircularProgressIndicator());
      } else if (state.notes.isEmpty) {
        body = RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 48),
              Icon(Icons.note_alt_outlined, size: 72, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Sin anotaciones todavía',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Registra tus entradas y salidas para construir tu bitácora de trading.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      } else {
        body = RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.separated(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 96,
            ),
            itemCount: state.notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _JournalEntryCard(
              note: state.notes[index],
              onOpenDetail: () => _openDetail(state.notes[index]),
              onEdit: () => _openEdit(state.notes[index]),
              onDelete: () => _confirmDelete(state.notes[index]),
            ),
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
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
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

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.note,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
  });

  final TradeNote note;
  final VoidCallback onOpenDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy – HH:mm');

  Color _trendColor(BuildContext context) =>
      note.exitPrice != null && note.exitPrice! >= note.entryPrice
      ? Colors.green
      : Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onOpenDetail,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(note.symbol.substring(0, 1)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${note.side.toUpperCase()} • ${_dateFormat.format(note.entryAt.toLocal())}',
                          style: captionStyle,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PopupMenuButton<_JournalCardAction>(
                        tooltip: 'Acciones',
                        onSelected: (action) {
                          switch (action) {
                            case _JournalCardAction.edit:
                              onEdit();
                              break;
                            case _JournalCardAction.delete:
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<_JournalCardAction>(
                            value: _JournalCardAction.edit,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Editar'),
                            ),
                          ),
                          PopupMenuItem<_JournalCardAction>(
                            value: _JournalCardAction.delete,
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.delete_outline),
                              title: Text('Eliminar'),
                            ),
                          ),
                        ],
                      ),
                      if (note.exitPrice != null && note.exitAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Chip(
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Exit ${_dateFormat.format(note.exitAt!.toLocal())}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Entrada',
                    value: '\$${note.entryPrice.toStringAsFixed(2)}',
                  ),
                  _InfoTile(
                    label: 'Tamaño',
                    value: note.size != null
                        ? note.size!.toStringAsFixed(4)
                        : '-',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Salida',
                    value: note.exitPrice != null
                        ? '\$${note.exitPrice!.toStringAsFixed(2)}'
                        : '-',
                    valueColor: note.exitPrice != null
                        ? _trendColor(context)
                        : null,
                  ),
                  _InfoTile(
                    label: 'Resultado',
                    value: _calculateResult(),
                    valueColor: _trendColor(context),
                  ),
                ],
              ),
              if (note.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(note.notes, style: theme.textTheme.bodyMedium),
              ],
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: note.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _calculateResult() {
    if (note.exitPrice == null || note.size == null) return '-';
    final diff = (note.exitPrice! - note.entryPrice) * note.size!;
    final prefix = diff >= 0 ? '+' : '-';
    return '$prefix\$${diff.abs().toStringAsFixed(2)}';
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.labelSmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.textTheme.titleMedium?.color,
          ),
        ),
      ],
    );
  }
}

enum _JournalCardAction { edit, delete }
