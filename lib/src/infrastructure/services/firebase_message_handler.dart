import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/utils/logger.dart';

/// Handler de mensajes Firebase en background
/// DEBE ser una función top-level (fuera de clases)
/// Se ejecuta cuando la app está cerrada o en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Mensaje recibido en background: ${message.messageId}');

  // Aquí puedes procesar el mensaje silenciosamente
  // NO se debe mostrar UI aquí (la notificación se muestra automáticamente)

  final data = message.data;

  if (data['type'] == 'trading_alert' || data['type'] == 'price_alert') {
    final symbol = data['symbol'];
    final currentPrice = data['currentPrice'];
    final priceChange = data['priceChange'];

    AppLogger.info('🚨 Alerta de trading recibida para $symbol');
    AppLogger.info('💰 Precio actual: $currentPrice');
    AppLogger.info('📉 Cambio: $priceChange%');

    // Procesar análisis IA si está disponible
    if (data.containsKey('analysis')) {
      final analysis = data['analysis'];
      if (analysis is String) {
        // Si el análisis viene como string JSON
        try {
          final analysisMap = jsonDecode(analysis) as Map<String, dynamic>;
          _logAIAnalysis(analysisMap, symbol.toString());
        } catch (e) {
          AppLogger.error('Error al parsear análisis IA: $e');
        }
      } else if (analysis is Map<String, dynamic>) {
        // Si el análisis viene como Map directamente
        _logAIAnalysis(analysis, symbol.toString());
      }
    } else {
      // Formato antiguo sin IA
      final dropPercent = data['dropPercent'];
      AppLogger.info('Alerta de precio para $symbol: $dropPercent%');
    }
  }
}

/// Registra el análisis IA en los logs
void _logAIAnalysis(Map<String, dynamic> analysis, String symbol) {
  final recommendation = analysis['recommendation'] ?? 'UNKNOWN';
  final confidence = analysis['confidence'] ?? 0;
  final reasoning = analysis['reasoning'] ?? 'Sin razonamiento disponible';
  final aiEngine = analysis['aiEngine'] ?? 'unknown';
  final newsContext = analysis['newsContext'];

  AppLogger.info('🤖 Análisis IA para $symbol:');
  AppLogger.info('   📊 Recomendación: $recommendation');
  AppLogger.info('   🎯 Confianza: $confidence%');
  AppLogger.info('   🧠 Motor IA: $aiEngine');
  AppLogger.info('   💭 Razonamiento: $reasoning');

  if (newsContext != null && newsContext is List && newsContext.isNotEmpty) {
    AppLogger.info('   📰 Contexto de noticias:');
    for (final news in newsContext) {
      AppLogger.info('      • $news');
    }
  }
}
