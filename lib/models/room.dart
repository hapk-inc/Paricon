import 'dart:convert';

import 'roomDetails.dart';

class Room {
  final List? players;
  final bool? isGameStarted;
  final RoomDetails details;
  const Room(
      {this.players, required this.isGameStarted, required this.details});

  Map<String, dynamic> toMap() {
    return {
      if (players != null) 'players': players,
      'isGameStarted': isGameStarted,
      'details': details.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory Room.fromJson(String source) => Room.fromMap(json.decode(source));

  factory Room.fromMap(Map fromSnapshot) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);
    return Room(
      players: Map<String, dynamic>.from(fromSnapshot["players"]).keys.toList(),
      isGameStarted: map['isGameStarted'],
      details: RoomDetails.fromMap(map['details']),
    );
  }

  factory Room.createRoom(String level, int maxCount, String uid) => Room(
        isGameStarted: false,
        details: RoomDetails.createDetails(level, maxCount, uid),
      );
}
