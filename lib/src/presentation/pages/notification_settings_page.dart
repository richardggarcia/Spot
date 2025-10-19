import 'dart:io';

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

  // Lista de todas las cryptos disponibles
  final List<String> _availableCryptos = [
    'BTC', 'ETH', 'BNB', 'SOL', 'XRP',
    'LINK', 'LTC', 'BCH', 'TON', 'SUI',
    'MNT', 'RON', 'KCS', 'BGB',
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

      // Obtener token FCM
      _fcmToken = NotificationService.fcmToken;

      // Verificar si las notificaciones están habilitadas
      _notificationsEnabled = await NotificationService.areNotificationsEnabled();

      // Obtener información del dispositivo del backend
      if (_fcmToken != null) {
        _deviceInfo = await NotificationService.getDeviceInfo();

        if (_deviceInfo != null) {
          // Cargar preferencias guardadas
          final cryptos = _deviceInfo!['cryptos'] as List<dynamic>?;
          if (cryptos != null) {
            _selectedCryptos = Set<String>.from(cryptos);
          } else {
            // Por defecto, seleccionar todas
            _selectedCryptos = Set<String>.from(_availableCryptos);
          }

          final minDrop = _deviceInfo!['minDropPercent'] as num?;
          if (minDrop != null) {
            _minDropPercent = minDrop.toDouble();
          }
        } else {
          // Si no hay info del dispositivo, usar valores por defecto
          _selectedCryptos = Set<String>.from(_availableCryptos);
        }
      }
    } catch (e) {
      AppLogger.error('Error al cargar configuración', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar configuración: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreferences() async {
    try {
      setState(() => _isLoading = true);

      await NotificationService.updatePreferences(
        cryptos: _selectedCryptos.toList(),
        minDropPercent: _minDropPercent,
        preferences: {'enabled': _notificationsEnabled},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias guardadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error al guardar preferencias', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
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
          content: Text('Selecciona al menos una crypto'),
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
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notificación de prueba enviada para $symbol'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error al enviar notificación de prueba', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e'),
            backgroundColor: Colors.red,
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
    // Mostrar advertencia si es iOS
    if (Platform.isIOS) {
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

  Widget _buildInfoRow(String label, String value, Color color) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
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
