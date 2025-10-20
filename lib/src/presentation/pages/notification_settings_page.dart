import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../infrastructure/services/notification_service.dart';
import '../widgets/premium_app_bar.dart';

/// Página de configuración de notificaciones push
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = true;
  bool _isLoading = true;
  String? _fcmToken;
  Map<String, dynamic>? _deviceInfo;
  double _minDropPercent = 3;

  // Lista de todas las cryptos disponibles (actualizada con nuevas opciones)
  final List<String> _availableCryptos = [
    'BTC', 'ETH', 'BNB', 'SOL', 'XRP', 'LINK', 'BCH', 'LTC',
    'TON', 'SUI', 'DOGE', 'ADA', 'AVAX', 'DOT', 'MATIC', 'UNI',
    'ATOM', 'FIL', 'TRX', 'ETC', 'MNT', 'KCS', 'RON', 'BGB',
  ];

  Set<String> _selectedCryptos = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => _isLoading = true);

      if (kIsWeb) {
        // En web, solicitar permisos de notificación del navegador
        AppLogger.info('Ejecutando en web - solicitando permisos de notificación');
        
        try {
          _notificationsEnabled = await NotificationService.areNotificationsEnabled();
          _fcmToken = NotificationService.fcmToken ?? 'web-token-${DateTime.now().millisecondsSinceEpoch}';
          
          _selectedCryptos = {'BTC', 'ETH', 'BNB', 'SOL', 'XRP'};
          _minDropPercent = 3.0;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_notificationsEnabled 
                  ? '🌐 Notificaciones web activadas' 
                  : '🌐 Haz clic en "Permitir" para activar notificaciones'),
                backgroundColor: _notificationsEnabled ? Colors.green : Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          _useDefaultSettings();
        }
        return;
      }

      // Solo para móvil: obtener token FCM
      _fcmToken = NotificationService.fcmToken;

      // Verificar permisos de notificaciones (solo móvil)
      try {
        _notificationsEnabled = await NotificationService.areNotificationsEnabled()
            .timeout(const Duration(seconds: 1));
      } catch (e) {
        AppLogger.error('Error obteniendo permisos de notificación', e);
        _notificationsEnabled = false;
      }

      // Obtener información del dispositivo del backend con timeout (solo móvil)
      if (_fcmToken != null) {
        try {
          _deviceInfo = await NotificationService.getDeviceInfo()
              .timeout(const Duration(seconds: 2));

          if (_deviceInfo != null) {
            // Cargar preferencias guardadas del backend
            final cryptos = _deviceInfo!['cryptos'] as List<dynamic>?;
            if (cryptos != null) {
              _selectedCryptos = Set<String>.from(cryptos);
            } else {
              // Por defecto, seleccionar las principales
              _selectedCryptos = {'BTC', 'ETH', 'BNB', 'SOL', 'XRP'};
            }

            final minDrop = _deviceInfo!['minDropPercent'] as num?;
            if (minDrop != null) {
              _minDropPercent = minDrop.toDouble();
            }
          } else {
            AppLogger.warning('No se pudo obtener información del dispositivo del backend');
            _useDefaultSettings();
          }
        } catch (e) {
          AppLogger.error('Error conectando con backend, usando configuración local', e);
          _useDefaultSettings();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Modo offline: usando configuración local'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        AppLogger.warning('No hay token FCM disponible');
        _useDefaultSettings();
      }
    } catch (e) {
      AppLogger.error('Error general al cargar configuración', e);
      _useDefaultSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar configuración: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Configuración por defecto cuando hay problemas de conectividad
  void _useDefaultSettings() {
    _selectedCryptos = {'BTC', 'ETH', 'BNB', 'SOL', 'XRP'};
    _minDropPercent = 3.0;
    _notificationsEnabled = false; // Por seguridad, deshabilitado por defecto
  }

  Future<void> _savePreferences() async {
    try {
      setState(() => _isLoading = true);

      // Validar que hay al menos una crypto seleccionada si están habilitadas las notificaciones
      if (_notificationsEnabled && _selectedCryptos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Selecciona al menos una criptomoneda'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Intentar guardar con timeout
      await NotificationService.updatePreferences(
        cryptos: _selectedCryptos.toList(),
        minDropPercent: _minDropPercent,
        preferences: {'enabled': _notificationsEnabled},
      ).timeout(const Duration(seconds: 3));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Preferencias guardadas correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error al guardar preferencias', e);
      
      if (mounted) {
        var errorMessage = 'Error al guardar';
        if (e.toString().contains('TimeoutException')) {
          errorMessage = '⏱️ Timeout: verifica tu conexión a internet';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = '🌐 Sin conexión: configuración guardada localmente';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _savePreferences,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendTestNotification() async {
    if (_selectedCryptos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecciona al menos una crypto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_notificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Activa las notificaciones primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final symbol = _selectedCryptos.first;
      await NotificationService.sendTestNotification(
        symbol: symbol,
        dropPercent: -_minDropPercent,
      ).timeout(const Duration(seconds: 3));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔔 Notificación de prueba enviada para $symbol'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error al enviar notificación de prueba', e);
      
      if (mounted) {
        var errorMessage = 'Error al enviar notificación';
        if (e.toString().contains('TimeoutException')) {
          errorMessage = '⏱️ Timeout: verifica tu conexión';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = '🌐 Sin conexión a internet';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: const PremiumAppBar(title: 'Configuración de Notificaciones'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: !_isLoading
          ? FloatingActionButton.extended(
              onPressed: _savePreferences,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            )
          : null,
    );

  Widget _buildContent() {
    // Mostrar advertencia si es iOS (solo en móvil, no en web)
    if (!kIsWeb && Platform.isIOS) {
      return _buildIOSWarning();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusCard(),
        const SizedBox(height: 16),
        _buildToggleCard(),
        const SizedBox(height: 16),
        _buildThresholdCard(),
        const SizedBox(height: 16),
        _buildCryptoSelector(),
        const SizedBox(height: 16),
        _buildTestButton(),
        const SizedBox(height: 80), // Espacio para el FAB
      ],
    );
  }

  Widget _buildIOSWarning() => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Notificaciones no disponibles en iOS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Las notificaciones push requieren una cuenta Apple Developer de pago (\$99/año).\n\n'
              'Opciones:\n'
              '• Usa Android para recibir notificaciones\n'
              '• Usa la versión web en desktop',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );

  Widget _buildStatusCard() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Estado del Servicio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Token FCM',
              _fcmToken != null
                  ? '${_fcmToken!.substring(0, 20)}...'
                  : 'No disponible',
              _fcmToken != null ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Permisos',
              _notificationsEnabled ? 'Concedidos' : 'Denegados',
              _notificationsEnabled ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Backend',
              _deviceInfo != null ? 'Conectado' : 'No registrado',
              _deviceInfo != null ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );

  Widget _buildInfoRow(String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14, 
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleCard() => Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications_active),
        title: const Text('Notificaciones Activadas'),
        subtitle: Text(
          _notificationsEnabled
              ? 'Recibirás alertas de caídas de precio'
              : 'No recibirás notificaciones',
        ),
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() => _notificationsEnabled = value);
        },
      ),
    );

  Widget _buildThresholdCard() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_down, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Umbral de Caída: ${_minDropPercent.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Notificar cuando la caída sea mayor o igual a:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Slider(
              value: _minDropPercent,
              min: 1,
              max: 10,
              divisions: 18,
              label: '${_minDropPercent.toStringAsFixed(1)}%',
              onChanged: (value) {
                setState(() => _minDropPercent = value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '10%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Widget _buildCryptoSelector() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.currency_bitcoin, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Cryptos a Monitorear',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_selectedCryptos.length}/${_availableCryptos.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCryptos = Set<String>.from(_availableCryptos);
                    });
                  },
                  icon: const Icon(Icons.check_box, size: 16),
                  label: const Text('Todas', style: TextStyle(fontSize: 12)),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCryptos.clear();
                    });
                  },
                  icon: const Icon(Icons.check_box_outline_blank, size: 16),
                  label: const Text('Ninguna', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCryptos.map((crypto) {
                final isSelected = _selectedCryptos.contains(crypto);
                return FilterChip(
                  selected: isSelected,
                  label: Text(crypto),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCryptos.add(crypto);
                      } else {
                        _selectedCryptos.remove(crypto);
                      }
                    });
                  },
                  selectedColor: Colors.blue.withAlpha(77),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

  Widget _buildTestButton() => Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading: const Icon(Icons.send, color: Colors.blue),
        title: const Text('Enviar Notificación de Prueba'),
        subtitle: const Text('Prueba que las notificaciones funcionan correctamente'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.blue),
          onPressed: _sendTestNotification,
        ),
        onTap: _sendTestNotification,
      ),
    );
}
