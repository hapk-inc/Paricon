import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localIcon.dart';

final roomNotifierProvider = ChangeNotifierProvider((_) => RoomNotifier());

class RoomNotifier extends ChangeNotifier {
  IconInfo _iconInfo;
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  IconInfo get iconInfo => _iconInfo;

  /*setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }*/

  set iconInfo(IconInfo value) {
    if (_iconInfo == value) return;
    _iconInfo = value;
    notifyListeners();
  }

  bool validateIcons(IconInfo info) {
    _loading = true;
    bool check;
    if (_iconInfo == null)
      _iconInfo = info;
    else
      check = _iconInfo.iconCode == info.iconCode;
    notifyListeners();
    return check;
  }
}
