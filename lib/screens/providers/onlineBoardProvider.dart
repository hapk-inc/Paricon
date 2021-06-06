import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/models/localPlayer.dart';

final onlineBoardNotifier =
    ChangeNotifierProvider<OnlineBoardNotifier>((_) => OnlineBoardNotifier());

class OnlineBoardNotifier extends ChangeNotifier {
  List<LocalPlayer> _players = List.empty(growable: true);
  List<LocalIcon> _icons = List.empty(growable: true);
  LocalPlayer? _myPlayer;

  List<LocalPlayer> get players => _players;

  replaceIcon(LocalIcon icon) {
    if (_icons.length < icon.iconNo!.toInt()) {
      _icons.add(icon);
      return;
    }
    if (_icons[icon.iconNo! - 1] == icon) return;
    print("Replacing Icon");
    print(icon);
    _icons[icon.iconNo! - 1] = icon;
  }

  replacePlayer(LocalPlayer player) {
    if (_players.length < player.playerNo!.toInt()) {
      _players.add(player);
      print(_players);
      return;
    }
    if (_players[player.playerNo! - 1] == player) return;

    _players[player.playerNo! - 1] = player;
    //notifyListeners();
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

  LocalPlayer get myPlayer => _myPlayer!;

  set myPlayer(LocalPlayer value) {
    if (_myPlayer == value) return;
    _myPlayer = value;
  }

  List<LocalPlayer> get sortByPoints {
    _players.sort((a, b) => b.pts!.compareTo(a.pts!));
    return _players;
  }
}
