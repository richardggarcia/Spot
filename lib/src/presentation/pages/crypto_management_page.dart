import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/crypto_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// Página para gestionar qué criptomonedas monitorear
class CryptoManagementPage extends StatefulWidget {
  const CryptoManagementPage({super.key});

  @override
  State<CryptoManagementPage> createState() => _CryptoManagementPageState();
}

class _CryptoManagementPageState extends State<CryptoManagementPage> {
  
  // Todas las cryptos disponibles con sus nombres completos (~20 cryptos)
  static const Map<String, String> _availableCryptos = {
    // Cryptos principales con historial completo
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum', 
    'BNB': 'BNB',
    'SOL': 'Solana',
    'XRP': 'XRP',
    'LINK': 'Chainlink',
    'BCH': 'Bitcoin Cash',
    'LTC': 'Litecoin',
    'TON': 'Toncoin',
    'SUI': 'Sui',
    'DOGE': 'Dogecoin',
    'ADA': 'Cardano',
    'AVAX': 'Avalanche',
    'DOT': 'Polkadot',
    'MATIC': 'Polygon',
    'UNI': 'Uniswap',
    'ATOM': 'Cosmos',
    'FIL': 'Filecoin',
    'TRX': 'TRON',
    'ETC': 'Ethereum Classic',
    // Cryptos con datos históricos limitados
    'MNT': 'Mantle (Sin historial)',
    'KCS': 'KuCoin Token (Sin historial)',
    'RON': 'Ronin (Sin historial)',
    'BGB': 'Bitget Token (Sin historial)',
  };

  Set<String> _selectedCryptos = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedCryptos();
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
        _selectedCryptos = AppConstants.defaultMonitoredSymbols.toSet();
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
            content: Text('✅ Configuración guardada. Reinicia la app para aplicar cambios.'),
            duration: Duration(seconds: 3),
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

  void _toggleCrypto(String symbol) {
    setState(() {
      if (_selectedCryptos.contains(symbol)) {
        // No permitir desseleccionar todas
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
      } else {
        _selectedCryptos.add(symbol);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedCryptos = _availableCryptos.keys.toSet();
    });
  }

  void _selectRecommended() {
    setState(() {
      // Cryptos recomendadas con buen historial
      _selectedCryptos = {
        'BTC', 'ETH', 'BNB', 'SOL', 'XRP', 'LINK', 'BCH', 'LTC'
      };
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
              // Header con stats y acciones rápidas
              Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seleccionadas: ${_selectedCryptos.length}/${_availableCryptos.length}',
                          style: AppTextStyles.h4.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _selectRecommended,
                              child: const Text('Recomendadas'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _selectAll,
                              child: const Text('Todas'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configura qué criptomonedas quieres monitorear. Las marcadas con "Sin historial" tienen datos limitados.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de cryptos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _availableCryptos.length,
                  itemBuilder: (context, index) {
                    final symbol = _availableCryptos.keys.elementAt(index);
                    final name = _availableCryptos[symbol]!;
                    final isSelected = _selectedCryptos.contains(symbol);
                    final hasLimitedData = name.contains('Sin historial');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => _toggleCrypto(symbol),
                        title: Row(
                          children: [
                            Text(
                              symbol,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            if (hasLimitedData) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.warning_amber,
                                size: 16,
                                color: isDark ? AppColors.darkAlert : AppColors.lightAlert,
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          name.replaceAll(' (Sin historial)', ''),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        secondary: hasLimitedData 
                          ? Icon(
                              Icons.info_outline,
                              color: isDark ? AppColors.darkAlert : AppColors.lightAlert,
                            )
                          : Icon(
                              Icons.currency_bitcoin,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                        activeColor: isDark ? AppColors.darkAccentPrimary : AppColors.lightAccentPrimary,
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
                    label: const Text('Guardar y Aplicar Cambios'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

}