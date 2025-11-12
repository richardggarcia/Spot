import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/utils/crypto_preferences.dart';
import '../../domain/ports/price_data_port.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// Página para gestionar qué criptomonedas monitorear
/// Permite agregar cualquier moneda mediante búsqueda dinámica
class CryptoManagementPage extends StatefulWidget {
  const CryptoManagementPage({super.key});

  @override
  State<CryptoManagementPage> createState() => _CryptoManagementPageState();
}

class _CryptoManagementPageState extends State<CryptoManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final _priceAdapter = ServiceLocator.get<PriceDataPort>();

  Set<String> _selectedCryptos = {};
  bool _isLoading = true;
  bool _isValidating = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _loadSelectedCryptos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedCryptos() async {
    try {
      final savedCryptos = await CryptoPreferences.getSelectedCryptos();

      setState(() {
        _selectedCryptos = savedCryptos.toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSelectedCryptos() async {
    try {
      await CryptoPreferences.saveSelectedCryptos(_selectedCryptos.toList());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Guardado. Reinicia la app para ver los cambios.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addCrypto() async {
    final symbol = _searchController.text.trim().toUpperCase();

    if (symbol.isEmpty) {
      setState(() {
        _validationError = 'Ingresa un símbolo';
      });
      return;
    }

    if (_selectedCryptos.contains(symbol)) {
      setState(() {
        _validationError = 'Ya está agregada';
      });
      return;
    }

    // Validar que el símbolo existe en las APIs
    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      final crypto = await _priceAdapter.getPriceForSymbol(symbol);

      if (crypto == null) {
        setState(() {
          _isValidating = false;
          _validationError = 'Símbolo no encontrado en APIs';
        });
        return;
      }

      setState(() {
        _selectedCryptos.add(symbol);
        _isValidating = false;
        _validationError = null;
        _searchController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $symbol agregada correctamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isValidating = false;
        _validationError = 'Error validando símbolo: ${e.toString()}';
      });
    }
  }

  void _removeCrypto(String symbol) {
    setState(() {
      if (_selectedCryptos.length > 1) {
        _selectedCryptos.remove(symbol);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Debe mantener al menos una criptomoneda seleccionada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Criptomonedas'),
        actions: [
          IconButton(
            onPressed: _saveSelectedCryptos,
            icon: const Icon(Icons.save),
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Header con información
              Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Criptomonedas Activas: ${_selectedCryptos.length}',
                          style: AppTextStyles.h4.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega monedas escribiendo su símbolo abajo. Las que aparecen en la lista ya están activas.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Campo de búsqueda
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Agregar Criptomoneda',
                              hintText: 'Ej: BTC, ETH, DOGE...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _isValidating
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _validationError,
                            ),
                            onSubmitted: (_) => _addCrypto(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isValidating ? null : _addCrypto,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa el símbolo (sin USDT). Ej: BTC, ETH, SOL, MNT, etc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Título de la lista
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.list,
                      size: 18,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Monedas Activas (toca 🗑️ para eliminar)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de cryptos seleccionadas
              Expanded(
                child: _selectedCryptos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied,
                            size: 64,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay criptomonedas activas',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega una usando el campo de arriba',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _selectedCryptos.length,
                      itemBuilder: (context, index) {
                        final symbol = _selectedCryptos.elementAt(index);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.currency_bitcoin,
                              color: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
                            ),
                            title: Text(
                              symbol,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: isDark ? AppColors.darkBearish : AppColors.lightBearish,
                              ),
                              onPressed: () => _removeCrypto(symbol),
                            ),
                          ),
                        );
                      },
                    ),
              ),

              // Footer con botón guardar
              Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveSelectedCryptos,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
