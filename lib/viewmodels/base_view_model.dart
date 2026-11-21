import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';

/// Estado común de carga y error para los ViewModels.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Ejecuta [task] marcando carga y guardando el mensaje de error si falla.
  /// Devuelve `true` si terminó bien.
  @protected
  Future<bool> runTask(Future<void> Function() task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await task();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
