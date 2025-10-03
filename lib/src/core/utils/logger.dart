import 'package:logger/logger.dart';

/// Utilidad centralizada para logging
class AppLogger {
  static final Logger _instance = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.e(message, error: error, stackTrace: stackTrace);
  }

  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.t(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.f(message, error: error, stackTrace: stackTrace);
  }
}
