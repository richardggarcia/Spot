import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trade_note.dart';
import '../theme/app_colors.dart';

const double _kFieldHeight = 56;

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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: viewInsets.add(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'EDITAR OPERACIÓN' : 'NUEVA OPERACIÓN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Ingresa los detalles de tu operación',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Side Selector - BIG SEGMENTED BUTTON
                _ProfessionalSideSelector(
                  selectedSide: _side,
                  onSideChanged: (side) => setState(() => _side = side),
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Symbol Input
                _ExchangeInputField(
                  controller: _symbolController,
                  labelText: 'PAR DE TRADING',
                  placeholder: 'BTC',
                  prefixIcon: Icons.currency_bitcoin,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el par de trading';
                    }
                    return null;
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Entry Section
                _SectionHeader(
                  title: 'DETALLES DE ENTRADA',
                  icon: Icons.login,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ExchangeInputField(
                        controller: _entryPriceController,
                        labelText: 'PRECIO DE ENTRADA',
                        placeholder: '0.00',
                        prefixIcon: Icons.price_check,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Campo requerido';
                          }
                          final parsed = double.tryParse(trimmed);
                          if (parsed == null) return 'Precio inválido';
                          return null;
                        },
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ExchangeInputField(
                        controller: _sizeController,
                        labelText: 'TAMAÑO DE POSICIÓN',
                        placeholder: '0.0000',
                        prefixIcon: Icons.pie_chart_outline,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ExchangeDateButton(
                  label: 'FECHA Y HORA DE ENTRADA',
                  value: _dateFormat.format(_entryAt.toLocal()),
                  onTap: () => _pickDate(isEntry: true),
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                // Exit Section
                _SectionHeader(
                  title: 'DETALLES DE SALIDA (Opcional)',
                  icon: Icons.logout,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ExchangeInputField(
                        controller: _exitPriceController,
                        labelText: 'PRECIO DE SALIDA',
                        placeholder: '0.00',
                        prefixIcon: Icons.trending_up,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ExchangeDateButton(
                        label: 'FECHA DE SALIDA',
                        value: _exitAt != null
                            ? _dateFormat.format(_exitAt!.toLocal())
                            : 'Seleccionar fecha',
                        onTap: () => _pickDate(isEntry: false),
                        allowClear: true,
                        onClear: () => setState(() => _exitAt = null),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Notes Section
                _SectionHeader(
                  title: 'INFORMACIÓN ADICIONAL',
                  icon: Icons.info_outline,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _ExchangeTextArea(
                  controller: _notesController,
                  labelText: 'NOTAS DE LA OPERACIÓN',
                  placeholder: 'Describe tu setup, condiciones del mercado, estrategia...',
                  maxLines: 4,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _ExchangeInputField(
                  controller: _tagsController,
                  labelText: 'ETIQUETAS',
                  placeholder: 'scalping, breakout, soporte',
                  prefixIcon: Icons.sell_outlined,
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size.fromHeight(_kFieldHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                            ? AppColors.darkAlert
                            : AppColors.lightAlert,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size.fromHeight(_kFieldHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isEditing ? 'Actualizar' : 'Guardar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
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

class _ProfessionalSideSelector extends StatelessWidget {
  const _ProfessionalSideSelector({
    required this.selectedSide,
    required this.onSideChanged,
    required this.isDark,
  });

  final String selectedSide;
  final ValueChanged<String> onSideChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSideChanged('buy'),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedSide == 'buy'
                    ? (isDark ? AppColors.darkBullish : AppColors.lightBullish)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: selectedSide == 'buy'
                        ? Colors.white
                        : (isDark ? AppColors.darkBullish : AppColors.lightBullish),
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BUY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selectedSide == 'buy'
                          ? Colors.white
                          : (isDark ? AppColors.darkBullish : AppColors.lightBullish),
                      ),
                    ),
                    Text(
                      'Compra',
                      style: TextStyle(
                        fontSize: 11,
                        color: selectedSide == 'buy'
                          ? Colors.white70
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSideChanged('sell'),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedSide == 'sell'
                    ? (isDark ? AppColors.darkBearish : AppColors.lightBearish)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: selectedSide == 'sell'
                        ? Colors.white
                        : (isDark ? AppColors.darkBearish : AppColors.lightBearish),
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SELL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selectedSide == 'sell'
                          ? Colors.white
                          : (isDark ? AppColors.darkBearish : AppColors.lightBearish),
                      ),
                    ),
                    Text(
                      'Venta',
                      style: TextStyle(
                        fontSize: 11,
                        color: selectedSide == 'sell'
                          ? Colors.white70
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  final String title;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
              ? AppColors.darkAccentPrimary.withValues(alpha: 0.2)
              : AppColors.lightAccentPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
}

class _ExchangeInputField extends StatelessWidget {
  const _ExchangeInputField({
    required this.controller,
    required this.labelText,
    required this.placeholder,
    required this.isDark,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String placeholder;
  final bool isDark;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;

  List<TextInputFormatter>? _buildInputFormatters() {
    // Si es un campo numérico decimal, agregamos formatters especiales
    if (keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
      return [
        // Permitir dígitos, punto y coma
        FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*$')),
        // Reemplazar coma por punto automáticamente
        TextInputFormatter.withFunction((oldValue, newValue) {
          final newText = newValue.text.replaceAll(',', '.');
          return TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _kFieldHeight,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textAlignVertical: TextAlignVertical.center,
            inputFormatters: _buildInputFormatters(),
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            validator: validator,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      size: 20,
                    )
                  : null,
              filled: true,
              fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBearish : AppColors.lightBearish,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBearish : AppColors.lightBearish,
                  width: 2,
                ),
              ),
              errorStyle: TextStyle(
                color: isDark ? AppColors.darkBearish : AppColors.lightBearish,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
}

class _ExchangeTextArea extends StatelessWidget {
  const _ExchangeTextArea({
    required this.controller,
    required this.labelText,
    required this.placeholder,
    required this.isDark,
    this.maxLines = 3,
  });

  final TextEditingController controller;
  final String labelText;
  final String placeholder;
  final bool isDark;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
}

class _ExchangeDateButton extends StatelessWidget {
  const _ExchangeDateButton({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isDark,
    this.allowClear = false,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isDark;
  final bool allowClear;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: _kFieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                if (allowClear && onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.clear,
                        size: 16,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
}
