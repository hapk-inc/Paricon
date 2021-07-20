import 'dart:convert';

class PlayerMetaData {
  final DateTime? lastOpened, lastTournamentPlayed;
  final DateTime currentTime;
  final List<String>? prevStats;

  PlayerMetaData({
    this.lastOpened,
    this.lastTournamentPlayed,
    required this.currentTime,
    this.prevStats,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        if (this.lastOpened != null)
          "lastOpened": this.lastOpened!.toIso8601String(),
        if (this.lastTournamentPlayed != null)
          "lastTournamentPlayed": this.lastTournamentPlayed!.toIso8601String(),
        "currentTime": this.currentTime.toIso8601String(),
        if (this.prevStats != null) "prevStats": prevStats,
      };

  factory PlayerMetaData.fromMap(Map fromSnapshot) {
    final map = Map<String, dynamic>.from(fromSnapshot);
    return PlayerMetaData(
        lastOpened: map['lastOpened'] == null
            ? null
            : DateTime.parse(map['lastOpened'] as String),
        currentTime: DateTime.parse(map['currentTime'] as String),
        lastTournamentPlayed: map['lastTournamentPlayed'] == null
            ? null
            : DateTime.parse(map['lastTournamentPlayed'] as String));
  }

  String toJson() => json.encode(toMap());

  factory PlayerMetaData.fromJson(String source) =>
      PlayerMetaData.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayerMetaData &&
        other.lastOpened == lastOpened &&
        other.prevStats == prevStats &&
        other.currentTime == currentTime &&
        other.lastTournamentPlayed == lastTournamentPlayed;
  }

  @override
  int get hashCode =>
      lastOpened.hashCode ^
      lastTournamentPlayed.hashCode ^
      currentTime.hashCode ^
      prevStats.hashCode;

  PlayerMetaData updateNow() => PlayerMetaData(
      currentTime: DateTime.now(),
      lastOpened: this.currentTime,
      lastTournamentPlayed: this.lastTournamentPlayed,
      prevStats: this.prevStats);
}
