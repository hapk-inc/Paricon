import 'dart:convert';

import 'package:meta/meta.dart';

class Stats {
  final int played;
  final int win;
  final double avg;

  Stats({
    @required this.played,
    @required this.win,
    @required this.avg,
  });

  Stats copyWith({
    int played,
    int win,
    double avg,
  }) {
    return Stats(
      played: played ?? this.played,
      win: win ?? this.win,
      avg: avg ?? this.avg,
    );
  }

  static Map<String, dynamic> toZero() => {
        'played': 0,
        'win': 0,
        'avg': 0,
      };

  Map<String, dynamic> toMap() {
    return {
      'played': played,
      'win': win,
      'avg': avg,
    };
  }

  factory Stats.fromMap(Map fromSnapshot) {
    Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);

    return Stats(
      played: map['played'],
      win: map['win'],
      avg: map['avg'] is int ? double.parse(map['avg'].toString()) : map['avg'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Stats.fromJson(String source) => Stats.fromMap(json.decode(source));

  @override
  String toString() => 'Stats(played: $played, win: $win, avg: $avg)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Stats &&
        other.played == played &&
        other.win == win &&
        other.avg == avg;
  }

  @override
  int get hashCode => played.hashCode ^ win.hashCode ^ avg.hashCode;

  Stats operator +(Stats stats) {
    double _avg = stats.avg - this.avg;
    _avg = _avg / (this.played + 1);
    _avg = this.avg + _avg;
    _avg = double.parse(_avg.toStringAsFixed(2));
    return Stats(
        played: (this.played + 1), win: (this.win + stats.win), avg: _avg);
  }
}
