import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localIcon.dart';

final AutoDisposeProvider<GameIconProvider>? gameIconProvider =
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
        icons.take(count).map((e) => _GameIconExt(e).name).toList();
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

  IconData? gameIcon(String? _gameIcon) => _GameIconExt.displayIcon(_gameIcon);

  Color? iconColor(String? color) {
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
      default:
        return Colors.white70;
    }
  }

  Color? iconBoxColor(String? color) {
    switch (color) {
      case 'red':
        return Colors.red[700];
      case 'green':
        return Colors.green[700];
      case 'indigo':
        return Colors.indigo[700];
      case 'brown':
        return Colors.brown[700];
      case 'purple':
        return Colors.purple[700];
      case 'orange':
        return Colors.orange[700];
      default:
        return Colors.black54;
    }
  }
}

enum GameIcons {
  accessibility,
  accessible,
  accessible_forward,
  account_balance,
  account_balance_wallet,
  account_box,
  account_circle,
  add_shopping_cart,
  alarm,
  anchor,
  android,
  aspect_ratio,
  assignment,
  autorenew,
  backup,
  book,
  bookmark,
  bug_report,
  build,
  cached,
  code,
  commute,
  dashboard,
  delete,
  donut_small,
  drag_indicator,
  eco,
  eject,
  euro_symbol,
  event_seat,
  extension,
  favorite,
  filter_alt,
  fingerprint,
  g_translate,
  gavel,
  gif,
  grade,
}

extension _GameIconExt on GameIcons {
  String get name => describeEnum(this);

  static IconData? displayIcon(String? icon) {
    switch (icon) {
      case "accessibility":
        return Icons.accessibility;
      case "accessible":
        return Icons.accessible;
      case "accessible_forward":
        return Icons.accessible_forward;
      case "account_balance":
        return Icons.account_balance;
      case "account_balance_wallet":
        return Icons.account_balance_wallet;
      case "account_box":
        return Icons.account_box;
      case "account_circle":
        return Icons.account_circle;
      case "add_shopping_cart":
        return Icons.add_shopping_cart;
      case "alarm":
        return Icons.alarm;
      case "anchor":
        return Icons.anchor;
      case "android":
        return Icons.android;
      case "aspect_ratio":
        return Icons.aspect_ratio;
      case "assignment":
        return Icons.assignment;
      case "autorenew":
        return Icons.autorenew;
      case "backup":
        return Icons.backup;
      case "book":
        return Icons.book;
      case "bookmark":
        return Icons.bookmark;
      case "bug_report":
        return Icons.bug_report;
      case "build":
        return Icons.build;
      case "cached":
        return Icons.cached;
      case "code":
        return Icons.code;
      case "commute":
        return Icons.commute;
      case "dashboard":
        return Icons.dashboard;
      case "delete":
        return Icons.delete;
      case "donut_small":
        return Icons.donut_small;
      case "drag_indicator":
        return Icons.drag_indicator;
      case "eco":
        return Icons.eco;
      case "eject":
        return Icons.eject;
      case "euro_symbol":
        return Icons.euro_symbol;
      case "event_seat":
        return Icons.event_seat;
      case "extension":
        return Icons.extension;
      case "favorite":
        return Icons.favorite;
      case "filter_alt":
        return Icons.filter_alt;
      case "fingerprint":
        return Icons.fingerprint;
      case "g_translate":
        return Icons.g_translate;
      case "gavel":
        return Icons.gavel;
      case "gif":
        return Icons.gif;
      case "grade":
        return Icons.grade;
      default:
        return Icons.cancel;
    }
  }
}
