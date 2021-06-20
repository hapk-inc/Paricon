import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final setGameProvider =
    ChangeNotifierProvider.autoDispose((_) => SetGameNotifier());

class SetGameNotifier extends ChangeNotifier {
  String _level = "";
  int _playerCount = 2;
  String _type = "normal";
  bool _loading = false;
  String _details = "Play Normal Game";

  String get details => _details;

  /*set details(String value) {
    _details = value;
  }*/

  bool get loading => _loading;

  set loading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

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

  String get type => _type;

  set type(String value) {
    if (_type == value) return;
    _type = value;
    if (_type == "normal")
      _details = "Play Normal Game";
    else if (_type == "closed")
      _details = "Others can't see your card";
    else if (_type == "orderWise") _details = "OrderWise game";

    notifyListeners();
  }
}
