import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  bool _appCargada = false;

  bool get appCargada => _appCargada;

  void marcarComoCargada() {
    _appCargada = true;
    notifyListeners();
  }

  void reiniciar() {
    _appCargada = false;
    notifyListeners();
  }
}
