import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Tournament {
  final List<String> participants;
  final Participant allTimeRecord;
  final Participant todayWinner;
  Tournament({
    required this.participants,
    required this.allTimeRecord,
    required this.todayWinner,
  });

  Tournament copyWith({
    List<String>? participants,
    Participant? allTimeRecord,
    Participant? todayWinner,
  }) {
    return Tournament(
      participants: participants ?? this.participants,
      allTimeRecord: allTimeRecord ?? this.allTimeRecord,
      todayWinner: todayWinner ?? this.todayWinner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'allTimeRecord': allTimeRecord.toMap(),
      'todayWinner': todayWinner.toMap(),
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      participants: List<String>.from(map['participants']),
      allTimeRecord: Participant.fromMap(map['allTimeRecord']),
      todayWinner: Participant.fromMap(map['todayWinner']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Tournament.fromJson(String source) =>
      Tournament.fromMap(json.decode(source));

  @override
  String toString() =>
      'Tournament(participants: $participants, allTimeRecord: $allTimeRecord, todayWinner: $todayWinner)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tournament &&
        listEquals(other.participants, participants) &&
        other.allTimeRecord == allTimeRecord &&
        other.todayWinner == todayWinner;
  }

  @override
  int get hashCode =>
      participants.hashCode ^ allTimeRecord.hashCode ^ todayWinner.hashCode;
}

class Participant {
  final String name, id;
  final double duration;
  final num gamesPlayed;
  final DateTime? dateTime;
  Participant({
    required this.name,
    required this.id,
    required this.duration,
    this.gamesPlayed = 0,
    this.dateTime,
  });

  Map<String, dynamic> toMap({bool newGame = false}) => <String, dynamic>{
        'name': name,
        'id': id,
        'duration': duration.toStringAsFixed(2),
        'gamesPlayed': newGame ? 1 : gamesPlayed,
        'date': DateFormat.yMMMd().format(DateTime.now())
      };

  factory Participant.fromMap(Map fromSnapshot) {
    final map = Map<String, dynamic>.from(fromSnapshot);

    return Participant(
      name: map['name'],
      id: map['id'] is int ? map['id'].toString() : map['id'],
      //duration: map['duration'] as double,
      duration: map['duration'] is double
          ? map['duration']
          : double.parse(map['duration'] as String),
      gamesPlayed: map['gamesPlayed'] ?? 0,
    );
  }

  Participant copyWith(
          {String? name, String? id, double? duration, num? gamesPlayed}) =>
      Participant(
        name: name ?? this.name,
        id: id ?? this.id,
        duration: duration ?? this.duration,
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      );

  String toJson() => json.encode(toMap());

  factory Participant.fromJson(String source) =>
      Participant.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Participant &&
        other.duration == duration &&
        other.name == name &&
        other.id == id &&
        other.gamesPlayed == gamesPlayed;
  }

  @override
  int get hashCode => duration.hashCode ^ name.hashCode ^ id.hashCode;
}
