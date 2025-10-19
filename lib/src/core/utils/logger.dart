import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';

/// Utilidad centralizada para logging
class AppLogger {
  static final Logger _instance = Logger(
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logWithBoth('🔍 DEBUG: $message', error, stackTrace);
    _instance.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logWithBoth('ℹ️ INFO: $message', error, stackTrace);
    _instance.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logWithBoth('⚠️ WARNING: $message', error, stackTrace);
    _instance.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logWithBoth('❌ ERROR: $message', error, stackTrace);
    _instance.e(message, error: error, stackTrace: stackTrace);
  }

  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _logWithBoth('🔬 VERBOSE: $message', error, stackTrace);
    _instance.t(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logWithBoth('💀 FATAL: $message', error, stackTrace);
    _instance.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log que funciona tanto en desarrollo como en web console
  static void _logWithBoth(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kIsWeb) {
      // En web, usar dart:developer para máxima visibilidad
      // ignore: avoid_web_libraries_in_flutter
      developer.log(message, level: 800, name: 'App', error: error, stackTrace: stackTrace);
      if (error != null) {
        developer.log('Error: $error', level: 1000, name: 'App');
      }
      if (stackTrace != null) {
        developer.log('StackTrace: $stackTrace', level: 900, name: 'App');
      }
    } else {
      // En móvil, developer.log también funciona bien
      developer.log(message, level: 800, name: 'App', error: error, stackTrace: stackTrace);
      if (error != null) {
        developer.log('Error: $error', level: 1000, name: 'App');
      }
      if (stackTrace != null) {
        developer.log('StackTrace: $stackTrace', level: 900, name: 'App');
      }
    }
  }

  /// Método especial para logs de notificaciones que siempre debe ser visible
  static void notification(String message, [dynamic error, StackTrace? stackTrace]) {
    final prefix = '🔔 NOTIFICATION: $message';
    if (kIsWeb) {
      // En web, usar dart:developer para máxima visibilidad
      // ignore: avoid_web_libraries_in_flutter
      developer.log(prefix, level: 800, name: 'NOTIFICATION');
      if (error != null) {
        // ignore: avoid_web_libraries_in_flutter
        developer.log('🔔 NOTIFICATION ERROR: $error', level: 800, name: 'NOTIFICATION');
      }
    } else {
      developer.log(prefix, level: 800, name: 'NOTIFICATION');
      if (error != null) {
        developer.log('Error: $error', level: 1000, name: 'NOTIFICATION');
      }
    }

    // También pasar por el logger normal
    _instance.i(message, error: error, stackTrace: stackTrace);
  }
}
