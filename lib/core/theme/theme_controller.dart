import 'package:flutter/material.dart';

/// Tema elegido, como el de la PWA: sigue al dispositivo hasta que la persona lo cambia
/// con el botón del encabezado.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Cambia al tema contrario del que se ve ahora.
  void toggle(Brightness current) {
    _mode = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
