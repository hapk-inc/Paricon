import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/enumFiles.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/models/localPlayer.dart';

final onlineBoardNotifier =
    ChangeNotifierProvider.autoDispose<OnlineBoardNotifier>(
  (_) => OnlineBoardNotifier(),
);

class OnlineBoardNotifier extends ChangeNotifier {
  List<LocalPlayer> _players = List.empty(growable: true);
  List<LocalIcon> _icons = List.empty(growable: true);
  LocalPlayer? _myPlayer;
  int _currentIndex = 0;
  GameType _type = GameType.normal;
  bool _orderWiseIcon = true;
  ConfettiController _confettiController =
      ConfettiController(duration: Duration(milliseconds: 500));

  /*List<Color>? _confettiColors;

  List<Color>? get confettiColors => _confettiColors;

  set confettiColors(List<Color>? value) {
    if (_confettiColors == value) return;
    _confettiColors = value;
    print(_confettiColors);

    notifyListeners();
  }*/

  ConfettiController get confettiController => _confettiController;

  String _confettiColors = "";

  String get confettiColors => _confettiColors;

  set confettiColors(String value) {
    if (_confettiColors == value) return;
    _confettiColors = value;
    notifyListeners();
  }

  bool get orderWiseIcon => _orderWiseIcon;

  set orderWiseIcon(bool value) {
    if (_orderWiseIcon == value) return;
    _orderWiseIcon = value;
  }

  GameType get type => _type;

  set type(GameType value) {
    if (_type == value) return;
    _type = value;
    //notifyListeners();
  }

  List<LocalIcon> _selectedIcons = List.empty(growable: true);

  List<LocalIcon> get selectedIcons => _selectedIcons;

  /*void addSelected(LocalIcon value) {
    _selectedIcons.add(value);
    notifyListeners();
  }*/

  bool _loading = false;
  bool _alreadyClicked = false;

  bool get alreadyClicked => _alreadyClicked;

  LocalPlayer get currentPlayer => players.isEmpty
      ? LocalPlayer(name: "Someone", color: "", pts: 0, playerNo: 0)
      : players[currentIndex.toInt()];

  String get level => _icons.length == 16
      ? "easy"
      : _icons.length == 42
          ? "medium"
          : "hard";

  double get myAvg {
    final int totalPts = icons.length ~/ 2;
    final double _avg = (myPlayer!.pts / totalPts) * 100;
    return double.parse(_avg.toStringAsFixed(2));
  }

  set alreadyClicked(bool value) {
    if (_alreadyClicked == value) return;
    _alreadyClicked = value;
    //notifyListeners();
  }

  bool get loading => _loading;

  set loading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;

  set currentIndex(int value) {
    if (_currentIndex == value) return;
    _currentIndex = value;
    notifyListeners();
  }

  List<LocalPlayer> get players => _players;

  replaceIcon(LocalIcon icon) {
    if (_icons.length < icon.iconNo!.toInt()) {
      _icons.add(icon);
      return;
    }
    if (_icons[icon.iconNo! - 1] == icon) return;

    print("Replacing Icon ${icon.iconNo} ${icon.iconCode}");
    _icons[icon.iconNo! - 1] = icon;
    notifyListeners();
  }

  replacePlayer(LocalPlayer player) {
    if (_players.length < player.playerNo.toInt()) {
      _players.add(player);
      print(_players);
      return;
    }
    if (_players[player.playerNo - 1] == player) return;

    _players[player.playerNo - 1] = player;
    notifyListeners();
  }

  List<LocalIcon> get icons => _icons;

  List<LocalIcon> coloredIcons(String color) {
    List<LocalIcon> mlist = [];
    final a = icons.where((element) => element.color == color).toList();
    a.forEach(
          (element) {
        if (!mlist.any((_list) => _list.iconCode == element.iconCode))
          mlist.add(element);
      },
    );

    return mlist;
  }

  LocalPlayer? get myPlayer => _myPlayer;

  set myPlayer(LocalPlayer? value) {
    if (_myPlayer == value) return;
    _myPlayer = value!;
    notifyListeners();
  }

  List<LocalPlayer> get sortByPoints {
    _players.sort((a, b) => b.pts.compareTo(a.pts));
    return _players;
  }

  init() {
    _icons.clear();
    _players.clear();
    _loading = false;
    _selectedIcons.clear();
    _myPlayer = null;
    //notifyListeners();
  }
}
