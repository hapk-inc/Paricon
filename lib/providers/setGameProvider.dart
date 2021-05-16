import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final setGameProvider = ChangeNotifierProvider((_) => SetGameNotifier());

class SetGameNotifier extends ChangeNotifier {
  String _level = "Easy";
  int _playerCount = 2;

  String get level => _level;

  set level(String value) {
    if (_level == value) return;
    _level = value;
    notifyListeners();
  }

  int get playerCount => _playerCount;

  set playerCount(int value) {
    if (_playerCount == value) return;
    _playerCount = value;
    notifyListeners();
  }
}
