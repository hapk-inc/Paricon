import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';

class Board {
  final List players;
  final List icons;
  final String? currentID;
  //final bool isGameOver;
  final int iconsFound;
  Board({
    required this.players,
    required this.icons,
    required this.currentID,
    //@required this.isGameOver,
    required this.iconsFound,
  });

  factory Board.fromMap(Map fromSnapshot) {
    final map = Map<String, dynamic>.from(fromSnapshot);
    final mPlayers = map['players'];
    final mIcons = map['icons'];

    //Arrange icons and players based on iconNo and playerNo
    final sortedIcons = SplayTreeMap.from(
      mIcons,
      (a, b) => mIcons[a]["iconNo"].compareTo(mIcons[b]["iconNo"]),
    );
    //Arrange icons and players based on iconNo and playerNo
    final sortedPlayers = SplayTreeMap.from(
      mPlayers,
      (a, b) => mPlayers[a]["playerNo"].compareTo(mPlayers[b]["playerNo"]),
    );
    final Board _board = Board(
      players:
          Map<String, dynamic>.from(sortedPlayers).keys.toList(growable: false),
      icons:
          Map<String, dynamic>.from(sortedIcons).keys.toList(growable: false),
      currentID: map['currentID'], iconsFound: map['iconsFound'] ?? 0,
      //isGameOver: map['isGameOver'],
    );
    return _board;
  }

  //String toJson() => json.encode(toMap());

  factory Board.fromJson(String source) => Board.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Board(players: $players, icons: $icons, currentID: $currentID)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is Board &&
        listEquals(other.players, players) &&
        listEquals(other.icons, icons) &&
        other.currentID == currentID &&
        //other.isGameOver == isGameOver;
        other.iconsFound == iconsFound;
  }

  @override
  int get hashCode {
    return players.hashCode ^
        icons.hashCode ^
        currentID.hashCode ^
        //isGameOver.hashCode;
        iconsFound.hashCode;
  }
}
