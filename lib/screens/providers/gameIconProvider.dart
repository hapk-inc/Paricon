import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/gameIcons.dart';
import 'package:paricon/models/localIcon.dart';

final AutoDisposeProvider<GameIconProvider> gameIconProvider =
    Provider.autoDispose<GameIconProvider>((_) => GameIconProvider());

class GameIconProvider {
  String get generateRandomID {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(
        12, (index) => _chars[Random.secure().nextInt(_chars.length)]).join();
  }

  int iconCount(String level) {
    //16 or 30 for easy
    final String _level = level.toLowerCase();
    return _level == "easy"
        ? 16
        : _level == "medium"
            ? 42
            : 72;
  }

  int crossAxisCount(int icons) {
    switch (icons) {
      case 16:
        return 4;
      case 42:
        return 7;
      case 72:
        return 9;
      default:
        return 0;
    }
  }

  List<String> getIcons(String level) {
    final int count = iconCount(level) ~/ 2;

    final icons = List.from(GameIcons.values)..shuffle();

    List<String> setIcons =
        icons.take(count).map((e) => GameIconExt(e).name).toList();
    return (setIcons + setIcons)..shuffle();
  }

  List<LocalIcon> generateIcons(String level) {
    final int _count = iconCount(level);
    final _icons = getIcons(level);
    List<LocalIcon> a = List.generate(
      _count,
      (i) => LocalIcon(iconCode: _icons[i], iconNo: i + 1, isFound: false),
    );
    return a;
  }

  IconData? gameIcon(String? _gameIcon) => GameIconExt.displayIcon(_gameIcon);

  Color iconColor(String color) {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'indigo':
        return Colors.indigo;
      case 'brown':
        return Colors.brown;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;

      default:
        return Colors.white70;
    }
  }

  Color iconBoxColor(String color) {
    switch (color) {
      case 'red':
        return Colors.redAccent;
      case 'green':
        return Colors.lightGreen;
      case 'indigo':
        return Colors.indigoAccent;
      case 'brown':
        return Colors.brown[700]!;
      case 'purple':
        return Colors.purpleAccent;
      case 'orange':
        return Colors.orangeAccent;
      case 'blue':
        return Colors.blueAccent;
      case 'pink':
        return Colors.pinkAccent;
      default:
        return Colors.white30;
    }
  }
}
