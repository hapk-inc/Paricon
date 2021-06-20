import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

extension GameIconExt on GameIcons {
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
