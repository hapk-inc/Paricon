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
    return Board(
      players: Map<String, dynamic>.from(mPlayers).keys.toList(growable: false),
      icons: Map<String, dynamic>.from(mIcons).keys.toList(growable: false),
      currentID: map['currentID'], iconsFound: map['iconsFound'] ?? 0,
      //isGameOver: map['isGameOver'],
    );
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
