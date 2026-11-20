import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Cliente HTTP de la API.
///
/// - Agrega `Authorization: Bearer` en las peticiones autenticadas.
/// - Si la API responde 401, intenta renovar el access token con el refresh
///   token una sola vez y repite la petición.
/// - Convierte las respuestas de error en [ApiException].
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    http.Client? httpClient,
    String? baseUrl,
  }) : _tokens = tokenStorage,
       _http = httpClient ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final TokenStorage _tokens;
  final http.Client _http;
  final String _baseUrl;

  /// Se llama cuando la sesión ya no se puede renovar (refresh inválido).
  void Function()? onSessionExpired;

  Future<void>? _refreshing;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) => _send('GET', path, query: query, auth: auth);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    required bool auth,
    bool retried = false,
  }) async {
    final uri = _buildUri(path, query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await _tokens.readAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      response = await http.Response.fromStream(
        await _http.send(request).timeout(ApiConfig.timeout),
      );
    } catch (e) {
      throw ApiException.network(e);
    }

    if (response.statusCode == 401 && auth && !retried) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(
          method,
          path,
          query: query,
          body: body,
          auth: auth,
          retried: true,
        );
      }
      onSessionExpired?.call();
    }

    return _handle(response);
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        for (final e in query.entries)
          if (e.value != null) e.key: e.value.toString(),
      },
    );
  }

  dynamic _handle(http.Response response) {
    final status = response.statusCode;
    final text = utf8.decode(response.bodyBytes);
    if (status >= 200 && status < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }
    try {
      final json = jsonDecode(text);
      if (json is Map<String, dynamic>) {
        throw ApiException.fromProblem(status, json);
      }
    } on FormatException {
      // La respuesta no es JSON; se reporta abajo.
    }
    throw ApiException(status: status, code: 'HTTP_$status', detail: text);
  }

  /// Renueva los tokens. Si hay varias peticiones con 401 a la vez,
  /// comparten el mismo refresh.
  Future<bool> _tryRefresh() async {
    _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
    try {
      await _refreshing;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _doRefresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) throw StateError('Sin refresh token');
    final json =
        await _send(
              'POST',
              '/auth/refresh',
              body: {'refreshToken': refreshToken},
              auth: false,
            )
            as Map<String, dynamic>;
    await _tokens.save(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}
