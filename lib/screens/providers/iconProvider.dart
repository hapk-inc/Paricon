import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localIcon.dart';

final iconProvider = Provider.autoDispose<Icons>((_) => Icons());

class Icons {
  final List<int> _actionIcons = <int>[
    0xe55c, //Accessibility
    0xe55e, //accessible
    0xe55f, //accessible_forward
    0xe560, //account_balance
    0xe561, //account_balance_wallet
    0xe562, //account_box
    0xe563, //account_circle
    0xe579, //add_shopping_cart
    0xe58e, //alarm
    0xe59a, //anchor
    0xe59b, //android
    0xe5b7, //aspect_ratio
    0xe5b9, //assignment
    0xe5d2, //autorenew
    0xe5d7, //backup
    0xe5f6, //book
    0xe5f8, //bookmark
    0xe619, //bug_report
    0xe61a, //build
    0xe620, //cached
    0xe66a, //code
    0xe671, //commute
    0xe69b, //dashboard
    0xe6a1, //delete
    0xe6d3, //donut_small
    0xe6d7, //drag_indicator
    0xe6e4, //eco
    0xe6ea, //eject
    0xe705, //euro_symbol
    0xe70b, //event_seat
    0xe719, //extension
    0xe721, //favorite
    0xe73d, //filter_alt
    0xe74a, //fingerprint
    0xe789, //g_translate
    0xe78c, //gavel
    0xe78f, //gif
    0xe794, //grade
  ];

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

  List<int> getIcons(String level) {
    final int count = iconCount(level) ~/ 2;
    _actionIcons.forEach((element) {
      print("IconCode is " + element.toString());
    });
    List<int> icons = List.from(_actionIcons)..shuffle();
    List<int> setIcons = icons.take(count).toList();
    return (setIcons + setIcons)..shuffle();
  }

  List<LocalIcon> generateIcons(String level) {
    final int _count = iconCount(level);
    final List<int> _icons = getIcons(level);
    List<LocalIcon> a = List.generate(
      _count,
      (i) => LocalIcon(iconCode: _icons[i], iconNo: i + 1, isFound: false),
    );
    return a;
  }
}
