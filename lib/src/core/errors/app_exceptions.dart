/// Excepciones personalizadas de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Excepciones del dominio
class DomainException extends AppException {
  const DomainException(super.message, {super.code});

  factory DomainException.invalidSymbol(String symbol) {
    return DomainException('Símbolo inválido: $symbol', code: 'INVALID_SYMBOL');
  }

  factory DomainException.priceNotFound(String symbol) {
    return DomainException(
      'Precio no encontrado para: $symbol',
      code: 'PRICE_NOT_FOUND',
    );
  }

  factory DomainException.calculationError(String operation) {
    return DomainException(
      'Error en cálculo: $operation',
      code: 'CALCULATION_ERROR',
    );
  }
}

/// Excepciones de red/API
class NetworkException extends AppException {
  final dynamic originalError;

  const NetworkException(super.message, {super.code, this.originalError});

  factory NetworkException.timeout() {
    return const NetworkException('Tiempo de espera agotado', code: 'TIMEOUT');
  }

  factory NetworkException.noConnection() {
    return const NetworkException(
      'Sin conexión a internet',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.serverError([int? statusCode]) {
    return NetworkException(
      'Error del servidor${statusCode != null ? ' ($statusCode)' : ''}',
      code: 'SERVER_ERROR',
    );
  }

  factory NetworkException.notFound() {
    return const NetworkException('Recurso no encontrado', code: 'NOT_FOUND');
  }
}

/// Excepciones de API
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(super.message, {super.code, this.statusCode});
}

/// Excepciones de caché
class CacheException extends AppException {
  const CacheException(super.message, {super.code});

  factory CacheException.notFound() {
    return const CacheException(
      'Datos no encontrados en caché',
      code: 'CACHE_NOT_FOUND',
    );
  }

  factory CacheException.expired() {
    return const CacheException(
      'Datos de caché expirados',
      code: 'CACHE_EXPIRED',
    );
  }

  factory CacheException.corrupted() {
    return const CacheException(
      'Datos de caché corruptos',
      code: 'CACHE_CORRUPTED',
    );
  }
}

/// Excepciones de estado
class StateException extends AppException {
  const StateException(super.message, {super.code});

  factory StateException.notInitialized() {
    return const StateException(
      'Estado no inicializado',
      code: 'NOT_INITIALIZED',
    );
  }

  factory StateException.invalidState() {
    return const StateException('Estado inválido', code: 'INVALID_STATE');
  }
}
