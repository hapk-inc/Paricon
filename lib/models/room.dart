import 'dart:convert';

import 'package:paricon/models/enumFiles.dart';

import 'roomDetails.dart';

class Room {
  final List? players;
  final bool isGameStarted;
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

  factory Room.createRoom(
          String level, int maxCount, String uid, String type) =>
      Room(
        isGameStarted: false,
        details: RoomDetails.createDetails(level, maxCount, uid, type),
      );
}

class ValidateRoom {
  final String id;
  final RoomStatus status;
  final bool alreadyIn;

  ValidateRoom({this.id = "", required this.status, this.alreadyIn = false});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ValidateRoom &&
        other.id == id &&
        other.alreadyIn == alreadyIn &&
        other.status == status;
  }

  @override
  int get hashCode => id.hashCode ^ alreadyIn.hashCode ^ status.hashCode;

  ValidateRoom copyWith({required RoomStatus roomStatus}) => ValidateRoom(
        id: id,
        status: roomStatus,
        alreadyIn: alreadyIn,
      );
}
