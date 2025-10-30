import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trade_note.dart';

class TradeNoteFormResult {
  const TradeNoteFormResult({
    required this.symbol,
    required this.entryPrice,
    required this.entryAt,
    required this.side,
    this.exitPrice,
    this.exitAt,
    this.size,
    this.notes = '',
    this.tags = const [],
  });

  final String symbol;
  final double entryPrice;
  final DateTime entryAt;
  final String side;
  final double? exitPrice;
  final DateTime? exitAt;
  final double? size;
  final String notes;
  final List<String> tags;
}

class TradeNoteFormSheet extends StatefulWidget {
  const TradeNoteFormSheet({super.key, this.initialNote});

  final TradeNote? initialNote;

  @override
  State<TradeNoteFormSheet> createState() => _TradeNoteFormSheetState();
}

class _TradeNoteFormSheetState extends State<TradeNoteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _symbolController;
  late final TextEditingController _entryPriceController;
  late final TextEditingController _exitPriceController;
  late final TextEditingController _sizeController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;

  late DateTime _entryAt;
  DateTime? _exitAt;
  late String _side;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  bool get _isEditing => widget.initialNote != null;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;

    _symbolController = TextEditingController(text: note?.symbol ?? '');
    _entryPriceController = TextEditingController(
      text: note != null ? note.entryPrice.toStringAsFixed(2) : '',
    );
    _exitPriceController = TextEditingController(
      text: note?.exitPrice != null ? note!.exitPrice!.toStringAsFixed(2) : '',
    );
    _sizeController = TextEditingController(
      text: note?.size != null ? note!.size!.toStringAsFixed(4) : '',
    );
    _notesController = TextEditingController(text: note?.notes ?? '');
    _tagsController = TextEditingController(
      text: note != null && note.tags.isNotEmpty ? note.tags.join(', ') : '',
    );

    _entryAt = note?.entryAt ?? DateTime.now().toUtc();
    _exitAt = note?.exitAt;
    _side = note?.side ?? 'buy';
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _entryPriceController.dispose();
    _exitPriceController.dispose();
    _sizeController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: viewInsets.add(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Editar operación' : 'Nueva operación',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _SectionTitle(label: 'Instrumento'),
              TextFormField(
                controller: _symbolController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Símbolo (ej: BTC)',
                  prefixIcon: Icon(Icons.currency_bitcoin),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un símbolo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const _SectionTitle(label: 'Detalles de entrada'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _entryPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio de entrada',
                        prefixIcon: Icon(Icons.price_check),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Ingresa un precio de entrada';
                        }
                        final parsed = double.tryParse(trimmed);
                        if (parsed == null) return 'Precio inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'buy', label: Text('Compra')),
                        ButtonSegment(value: 'sell', label: Text('Venta')),
                      ],
                      selected: <String>{_side},
                      onSelectionChanged: (selection) {
                        if (selection.isNotEmpty) {
                          setState(() => _side = selection.first);
                        }
                      },
                      showSelectedIcon: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DateButton(
                label: 'Fecha y hora de entrada',
                value: _dateFormat.format(_entryAt.toLocal()),
                onTap: () => _pickDate(isEntry: true),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(label: 'Salida (opcional)'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _exitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio de salida',
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateButton(
                      label: 'Fecha de salida',
                      value: _exitAt != null
                          ? _dateFormat.format(_exitAt!.toLocal())
                          : 'Selecciona fecha',
                      onTap: () => _pickDate(isEntry: false),
                      allowClear: true,
                      onClear: () => setState(() => _exitAt = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionTitle(label: 'Información adicional'),
              TextFormField(
                controller: _sizeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Tamaño posición',
                  prefixIcon: Icon(Icons.pie_chart_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notas (setup, contexto...)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (separadas por coma)',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _isEditing ? 'Actualizar operación' : 'Guardar operación',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isEntry}) async {
    final initial = isEntry ? _entryAt : _exitAt ?? DateTime.now().toUtc();
    final initialLocal = initial.toLocal();

    final date = await showDatePicker(
      context: context,
      initialDate: initialLocal,
      firstDate: DateTime(initialLocal.year - 1),
      lastDate: DateTime(initialLocal.year + 1),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialLocal),
    );
    if (time == null || !mounted) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();

    setState(() {
      if (isEntry) {
        _entryAt = combined;
      } else {
        _exitAt = combined;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final entryPrice = double.parse(_entryPriceController.text.trim());
    final exitPriceText = _exitPriceController.text.trim();
    final sizeText = _sizeController.text.trim();

    final result = TradeNoteFormResult(
      symbol: _symbolController.text.trim().toUpperCase(),
      entryPrice: entryPrice,
      entryAt: _entryAt,
      side: _side,
      exitPrice: exitPriceText.isEmpty ? null : double.tryParse(exitPriceText),
      exitAt: _exitAt,
      size: sizeText.isEmpty ? null : double.tryParse(sizeText),
      notes: _notesController.text.trim(),
      tags: _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
    );

    Navigator.of(context).pop(result);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        letterSpacing: 0.6,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
    this.allowClear = false,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool allowClear;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (allowClear && onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              tooltip: 'Quitar fecha',
            ),
        ],
      ),
    );
  }
}
