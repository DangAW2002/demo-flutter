import 'package:flutter/material.dart';

class ValentineProvider extends ChangeNotifier {
  bool _isValentineMode = false;

  bool get isValentineMode => _isValentineMode;

  void toggleValentineMode() {
    _isValentineMode = !_isValentineMode;
    notifyListeners();
  }
}
