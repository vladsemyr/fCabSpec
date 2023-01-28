import 'package:flutter/material.dart';

class LogNotifier extends ChangeNotifier {
  String _log = "";

  void add(String message) {
    _log = _log + message;
    notifyListeners();
  }
  
  String getAll() {
    return _log;
  }
}
