import 'dart:convert';
import 'dart:math';

import 'package:meta/meta.dart';

class RoomDetails {
  final int roomCode;
  final String level;
  final int maxCount;
  final String creatorID;
  const RoomDetails({
    @required this.roomCode,
    @required this.level,
    @required this.maxCount,
    @required this.creatorID,
  });

  Map<String, dynamic> toMap() => {
        'roomCode': roomCode,
        'level': level,
        'maxCount': maxCount,
        'creatorID': creatorID,
      };

  String toJson() => json.encode(toMap());

  factory RoomDetails.fromMap(Map fromSnapshot) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);
    return RoomDetails(
      roomCode: map['roomCode'],
      level: map['level'],
      maxCount: map['maxCount'],
      creatorID: map['creatorID'],
    );
  }

  factory RoomDetails.createDetails(String level, int maxCount, String uid) =>
      RoomDetails(
        roomCode: 100000 + Random.secure().nextInt(999999 - 100000),
        level: level,
        maxCount: maxCount,
        creatorID: uid,
      );
}
