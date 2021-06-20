import 'dart:convert';
import 'dart:math';

class RoomDetails {
  final int roomCode;
  final String level;
  final int maxCount;
  final String creatorID;
  final String type;

  const RoomDetails(
      {required this.roomCode,
      required this.level,
      required this.maxCount,
      required this.creatorID,
      required this.type});

  Map<String, dynamic> toMap() => {
        'roomCode': roomCode,
        'level': level,
        'maxCount': maxCount,
        'creatorID': creatorID,
        'type': type
      };

  String toJson() => json.encode(toMap());

  factory RoomDetails.fromMap(Map fromSnapshot) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);
    return RoomDetails(
      roomCode: map['roomCode'],
      level: map['level'],
      maxCount: map['maxCount'],
      creatorID: map['creatorID'],
      type: map['type'],
    );
  }

  factory RoomDetails.createDetails(
          String level, int maxCount, String uid, String type) =>
      RoomDetails(
        roomCode: 100000 + Random.secure().nextInt(999999 - 100000),
        level: level,
        maxCount: maxCount,
        creatorID: uid,
        type: type,
      );
}
