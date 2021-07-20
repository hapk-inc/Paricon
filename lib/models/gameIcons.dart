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

enum TournamentIcons { home, Settings }

const List<String> iconSounds = [
  "anklung",
  "boltJingle",
  "boneSnap",
  "cards",
  "catRattle",
  "chewing",
  "congaOpen",
  "cookie_sheet_2",
  "cookieSheet",
  "cookieTin",
  "cowbellLargeClosed",
  "cowbellLargeOpen",
  "cowbellSmallClosed",
  "cowbellSmallOpen",
  "cymbalHihatStick",
  "cymbalHihatFoot",
  "drumBass",
  "eggShaker",
  "handDrum",
  "maracasDbl",
  "music_boxTone1",
  "music_boxTone3",
  "pencil_tick_1",
  "pencilScrape",
  "pipe_thump2",
  "pipe_thump3",
  "pipeThump",
  "pvc",
  "rubber_toyShort1",
  "rubber_toyShort3",
  "rubber_toyShort5",
  "screw",
  "sprinkler",
  "stone1",
  "stone2",
  "stone3",
  "tabla_hiNa",
  "tabla_hiTuh",
  "tabla_hiTuut",
  "tabla_lo_geh_gliss",
  "timbale_HiCrosstick",
  "whistle_owl",
  "woodblock_pitched_LOWERsol",
  "woodblock_pitched_mi",
  "woodblock_pitched_sol",
  "woodblock_pitched_ti"
];

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

/*extension TournamentIconsExt on TournamentIcons{
  String get name => describeEnum(this);

  static IconData? displayIcon(String? icon) {
    switch (icon) {
      case "accessibility":
        return Icons.accessibility;
      case "home":
        return Icons.home;
        case ""
      default:
        return Icons.cancel;
    }
  }
}*/

const Map<String, IconData> actionIcons = <String, IconData>{
  "home": Icons.home,
  "done": Icons.done,
  "shopping cart": Icons.shopping_cart,
  "visibility": Icons.visibility,
  "face": Icons.face,
  "description": Icons.description,
  "favorite border": Icons.favorite_border,
  "lock": Icons.lock,
  "thumb up": Icons.thumb_up,
  "verified": Icons.verified,
  "lightbulb": Icons.lightbulb,
  "question answer": Icons.question_answer,
  "verified user": Icons.verified_user,
  "print": Icons.print,
  "work": Icons.work,
  "pets": Icons.pets,
  "room": Icons.room,
  "explore": Icons.explore,
  "done all": Icons.done_all,
  "supervisor account": Icons.supervisor_account,
  "pending": Icons.pending,
  "view in Ar": Icons.view_in_ar,
  "pan tool": Icons.pan_tool,
  "flight takeoff": Icons.flight_takeoff,
  "get app": Icons.get_app,
  "label": Icons.label,
  "translate": Icons.translate,
  "loyalty": Icons.loyalty,
  "nightlight round": Icons.nightlight_round,
  "sensors": Icons.sensors,
  "copyright": Icons.copyright,
  "bookmarks": Icons.bookmarks,
  "invert colors": Icons.invert_colors,
  "important devices": Icons.important_devices,
  "theaters": Icons.theaters,
  "opacity": Icons.opacity,
  "tour": Icons.tour,
  "http": Icons.http,
  "wifi protected setup": Icons.wifi_protected_setup,
  "polymer": Icons.polymer
};

/*const Map<String, IconData> alertIcons = <String, IconData>{
  "warning": Icons.warning,
  "notification important": Icons.notification_important
};*/

const Map<String, IconData> audioVideoIcons = <String, IconData>{};
