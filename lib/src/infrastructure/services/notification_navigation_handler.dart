import 'package:flutter/material.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/notification_data.dart';
import '../../presentation/pages/historical_view_page.dart';

/// Manejador de navegación para notificaciones
/// Permite navegar a páginas específicas cuando el usuario toca una notificación
class NotificationNavigationHandler {
  static final NotificationNavigationHandler _instance =
      NotificationNavigationHandler._internal();
  factory NotificationNavigationHandler() => _instance;
  NotificationNavigationHandler._internal();

  /// GlobalKey para acceder al navigator desde cualquier lugar
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navega a la página apropiada basándose en el payload de la notificación
  Future<void> handleNotificationTap(Map<String, dynamic> data) async {
    try {
      final notificationData = NotificationData.fromMap(data);

      AppLogger.info('Manejando tap de notificación: $notificationData');

      // Validar que los datos son suficientes para navegación
      if (!notificationData.isValidForNavigation) {
        AppLogger.warning(
          'Datos insuficientes para navegación: ${notificationData.type}',
        );
        return;
      }

      switch (notificationData.type) {
        case NotificationType.priceAlert:
          await _navigateToPriceAlert(notificationData);
          break;
        case NotificationType.general:
          // Notificación general, no requiere navegación
          AppLogger.info('Notificación general, sin navegación');
          break;
        case NotificationType.unknown:
          AppLogger.warning('Tipo de notificación desconocido');
          break;
      }
    } catch (e) {
      AppLogger.error('Error al manejar tap de notificación', e);
    }
  }

  /// Navega a la página de análisis histórico para una alerta de precio
  Future<void> _navigateToPriceAlert(NotificationData data) async {
    if (data.symbol == null) {
      AppLogger.error('Symbol no encontrado en datos de notificación');
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      AppLogger.error('Context no disponible para navegación');
      return;
    }

    AppLogger.info('Navegando a HistoricalViewPage para ${data.symbol}');

    // Navegar a la página de análisis histórico
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistoricalViewPage(
          symbol: data.symbol!,
          cryptoName: data.cryptoName ?? data.symbol!,
        ),
      ),
    );
  }

  /// Parsea el payload de string a Map usando NotificationData
  static Map<String, dynamic> parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return {};
    }

    try {
      final notificationData = NotificationData.fromPayloadString(payload);
      return notificationData.toMap();
    } catch (e) {
      AppLogger.error('Error al parsear payload de notificación', e);
      return {};
    }
  }
}
