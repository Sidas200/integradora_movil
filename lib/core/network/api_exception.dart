/// Error devuelto por la API en formato `application/problem+json` (RFC 9457).
class ApiException implements Exception {
  ApiException({
    required this.status,
    required this.code,
    this.title,
    this.detail,
    this.fieldErrors = const [],
  });

  final int status;

  /// Código estable del backend (VALIDATION_FAILED, INVALID_CREDENTIALS, ...).
  final String code;
  final String? title;
  final String? detail;
  final List<FieldError> fieldErrors;

  factory ApiException.fromProblem(int status, Map<String, dynamic> json) {
    final errors = (json['errors'] as List<dynamic>? ?? [])
        .map((e) => FieldError.fromJson(e as Map<String, dynamic>))
        .toList();
    return ApiException(
      status: status,
      code: json['code'] as String? ?? 'INTERNAL_ERROR',
      title: json['title'] as String?,
      detail: json['detail'] as String?,
      fieldErrors: errors,
    );
  }

  factory ApiException.network(Object error) => ApiException(
        status: 0,
        code: 'NETWORK_ERROR',
        detail: error.toString(),
      );

  /// Mensaje en español para mostrar al usuario según el código.
  String get userMessage {
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return 'Correo o contraseña incorrectos.';
      case 'EMAIL_IN_USE':
        return 'Ese correo ya está registrado.';
      case 'USERNAME_IN_USE':
        return 'Ese nombre de usuario ya está en uso.';
      case 'VALIDATION_FAILED':
        if (fieldErrors.isNotEmpty) {
          return fieldErrors.map((e) => '${e.field}: ${e.message}').join('\n');
        }
        return 'Hay datos inválidos.';
      case 'TOKEN_EXPIRED':
      case 'INVALID_SESSION':
        return 'Tu sesión expiró. Inicia sesión de nuevo.';
      case 'TOO_MANY_ATTEMPTS':
        return 'Demasiados intentos. Espera un momento.';
      case 'NOT_FOUND':
        return 'No se encontró el recurso.';
      case 'NETWORK_ERROR':
        return 'No se pudo conectar con el servidor.';
      default:
        return detail ?? title ?? 'Ocurrió un error ($status).';
    }
  }

  bool get isUnauthenticated => status == 401;

  @override
  String toString() => 'ApiException($status, $code, $detail)';
}

class FieldError {
  FieldError({required this.field, required this.code, required this.message});

  final String field;
  final String code;
  final String message;

  factory FieldError.fromJson(Map<String, dynamic> json) => FieldError(
        field: json['field'] as String? ?? '',
        code: json['code'] as String? ?? '',
        message: json['message'] as String? ?? '',
      );
}
