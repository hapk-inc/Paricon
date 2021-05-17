import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final prevStatsProvider = ChangeNotifierProvider<PrevStatsNotifier>(
  (_) => PrevStatsNotifier(),
);

class PrevStatsNotifier extends ChangeNotifier {
  String _level;
  bool _isWinner;
  bool _matchDraw;
  int _pts;
  int _rank;
  double _avg;

  String get level => _level;

  bool get isWinner => _isWinner;

  bool get matchDraw => _matchDraw;

  int get pts => _pts;

  int get rank => _rank;

  double get avg => _avg;

  setStats(String level, int pts, double avg, bool isWinner, bool isDraw) {
    _level = level;
    _pts = pts;
    _avg = avg;
    _isWinner = isWinner;
    _matchDraw = isDraw;
    notifyListeners();
  }
}
