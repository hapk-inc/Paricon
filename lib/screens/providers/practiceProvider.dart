import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/models/localPlayer.dart';

import 'authProvider.dart';
import 'databaseProvider.dart';

final practiceProvider = ChangeNotifierProvider((_) => PracticeNotifier());

final AutoDisposeFutureProviderFamily<String?, String> prevTimeRecordProvider =
    FutureProvider.autoDispose.family<String?, String>(
  (ref, level) async {
    final auth = ref.read(firebaseUserProvider!);
    final playerDatabase = ref.read(playerDatabaseProvider!(auth.uid));
    return playerDatabase.fetchPrevRecord(level);
  },
);

class PracticeNotifier extends ChangeNotifier {
  late List<LocalIcon> _icons;
  late List<LocalPlayer> _players;

  bool _gameOver = false;
  bool _isFirstClick = false;
  String _level = "easy";
  int _playerCount = 1;
  int _currentID = 0;
  bool _boardLoading = false;

  final List<String> colorNames = [
    'red',
    'green',
    'indigo',
    'brown',
    'purple',
    'orange'
  ]..shuffle();

  String? _compareIcon = "";

  late Stopwatch? _watch;
  Timer? _timer;
  bool _recordTime = false;

  bool get recordTime => _recordTime;

  set recordTime(bool value) {
    if (_recordTime == value) return;
    _recordTime = value;
    if (_recordTime) _playerCount = 1;
    notifyListeners();
  }

  PracticeNotifier() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch!.elapsed;
    // notify all listening widgets
    notifyListeners();
  }

  void timeStart() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _watch!.start();
    _isFirstClick = true;
    notifyListeners();
  }

  void timeStop() {
    if (_timer != null) _timer!.cancel();
    //_timer = null;
    _watch!.stop();
    _currentDuration = _watch!.elapsed;

    notifyListeners();
  }

  void reset() {
    timeStop();
    _watch!.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }

  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  bool get boardLoading => _boardLoading;

  @override
  void dispose() {
    if (_recordTime) timeStop();
    super.dispose();
  }

  set boardLoading(bool value) {
    _boardLoading = value;
    notifyListeners();
  }

  List<LocalIcon> get icons => _icons;

  set icons(List<LocalIcon> icons) {
    _icons = icons;
    notifyListeners();
  }

  bool get gameOver => _gameOver;

  set gameOver(bool value) {
    if (_gameOver == value) return;
    _gameOver = value;
    if (_gameOver && _recordTime) {
      timeStop();
    }
  }

  List<LocalPlayer> get players => _players;

  set players(List<LocalPlayer> value) {
    _players = value;
    notifyListeners();
  }

  replaceIcon(LocalIcon icon) {
    _boardLoading = true;
    _icons[icon.iconNo! - 1] = icon;

    notifyListeners();
  }

  int get currentID => _currentID;

  set currentID(int value) {
    if (_currentID == value) return;
    _currentID = value;
  }

  int get playerCount => _playerCount;

  set playerCount(int value) {
    if (_playerCount == value) return;
    _playerCount = value;
    _recordTime = false;
    notifyListeners();
  }

  String get level => _level;

  set level(String value) {
    if (_level == value) return;
    _level = value;
    notifyListeners();
  }

  createBoard() {
    players = List.generate(
      _playerCount,
      (index) => LocalPlayer(
        name: "PLAYER ${index + 1}",
        color: colorNames[index],
        pts: 0,
        playerNo: index + 1,
      ),
    );
  }

  void validateIcons(LocalIcon icon) async {
    if (!_isFirstClick && _recordTime) timeStart();

    replaceIcon(icon.setCheck(true));

    if (_compareIcon!.isEmpty) {
      _compareIcon = icon.iconCode!;
      _boardLoading = false;
      notifyListeners();
      return;
    }

    final bool validate = _compareIcon == icon.iconCode!;

    await Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (validate) {
          _icons = _icons
              .map((e) => e.isCheck ?? false
                  ? e.setFoundTrue(_players[_currentID].color!)
                  : e)
              .toList(growable: false);
          _players[_currentID].pts = (_players[_currentID].pts ?? 0) + 1;

          gameOver = _icons.every((element) => element.isFound ?? false);
        } else {
          _icons = _icons
              .map((e) => e.isCheck ?? false ? e.setCheck(false) : e)
              .toList(growable: false);
          if (!_recordTime) {
            _currentID++;
            if (_players.length == _currentID) _currentID = 0;
          }
        }
      },
    );

    _compareIcon = "";
    _boardLoading = false;
    notifyListeners();
  }
}
