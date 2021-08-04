import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/gameIcons.dart';
import 'package:paricon/models/localIcon.dart';

final AutoDisposeProvider<GameIconProvider> gameIconProvider =
    Provider.autoDispose<GameIconProvider>((_) => GameIconProvider());
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

class GameIconProvider {
  String get generateRandomID => List.generate(
      12, (index) => _chars[Random.secure().nextInt(_chars.length)]).join();

  int iconCount(String level) => level.toLowerCase() == "easy"
      ? 16
      : level == "medium"
          ? 42
          : 72;

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

  List<InitIcon> getIcons(String? level) {
    final int count = iconCount(level ?? "hard") ~/ 2;

    final icons = level == null
        ? List.from([...actionIcons.keys])
        : List.from([...basicIcons.keys, ...actionIcons.keys])
      ..shuffle();

    final sounds = List.from(iconSounds)..shuffle();

    List<InitIcon> initIcons = List.generate(
      count,
      (index) => InitIcon(
        level == null ? icons[index] : icons[index],
        sounds[index],
      ),
    );

    return (initIcons + initIcons)..shuffle();
  }

  List<LocalIcon> generateIcons(String level) {
    final int _count = iconCount(level);
    final _icons = getIcons(level);
    return List.generate(
        _count,
        (i) => LocalIcon(
            iconCode: _icons[i].icon, iconNo: i + 1, audio: _icons[i].audio));
  }

  List<LocalIcon> get tournamentIcons {
    final _icons = getIcons(null);
    return List.generate(
      iconCount("hard"),
      (i) => LocalIcon(
          iconCode: _icons[i].icon, iconNo: i + 1, audio: _icons[i].audio),
    );
  }

  IconData? gameIcon(String? icon) =>
      <String, IconData>{...basicIcons, ...actionIcons}[icon];

  /*IconData? tournamentGameIcons(String gameIcon) {
    final Map<String, IconData> map = actionIcons;
    final a = map[gameIcon];
    return a;
  }*/

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
      case 'blueGrey':
        return Colors.blueGrey;
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

  List<Color>? confettiColors(String color) {
    // print("confetti colors $color");
    switch (color) {
      case 'red':
        return const [
          //Colors.red.withOpacity(opacity),
          Colors.red,
          Colors.redAccent,
          // Colors.red.shade700,
          //Colors.red.shade900,
        ];
      case 'green':
        return const [
          Colors.green,
          Colors.greenAccent,
          Colors.lightGreen,
          Colors.greenAccent
        ];
      case 'indigo':
        return const [
          //Colors.indigo.shade900,
          //Colors.indigo.shade700,
          Colors.indigo,
          Colors.indigoAccent,
          //Colors.indigo.shade50,
        ];
      case 'brown':
        return const [
          //Colors.brown.shade200,
          Colors.brown,
          Colors.black87
          //Colors.brown.shade700,
          // Colors.brown.shade900,
        ];
      case 'purple':
        return const [
          // Colors.purple.shade900,
          Colors.purple,
          Colors.purpleAccent,
          //Colors.purple.shade200,
          //Colors.purple.shade50
        ];
      case 'orange':
        return const [
          Colors.orange,
          Colors.orangeAccent,
          Colors.deepOrange,
          Colors.deepOrangeAccent,
        ];
      case 'blue':
        return const [
          Colors.blue,
          Colors.blueAccent,
          Colors.blueGrey,
          Colors.lightBlue,
          Colors.lightBlueAccent
        ];
      case 'pink':
        return const [
          Colors.pink,
          Colors.pinkAccent,
          //Colors.pink.shade700,
          //Colors.pink.shade900,
        ];
      default:
        return null;
    }
  }
}
