/// Configuración de la API.
///
/// La URL se puede cambiar al ejecutar, por ejemplo para el backend local
/// (en el emulador de Android la PC es 10.0.2.2):
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
class ApiConfig {
  ApiConfig._();

  /// URL base de la API (incluye `/api/v1`). Por defecto, staging en Render.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://tdimp-api-staging.onrender.com/api/v1',
  );

  /// Tipo de cliente que exige el backend para recibir el refresh token en el JSON.
  static const String clientType = 'MOBILE';

  /// Render (plan gratis) tarda hasta ~1 min en despertar el servicio.
  static const Duration timeout = Duration(seconds: 75);
}
