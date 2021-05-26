import 'dart:convert';

class LocalPlayer {
  final String? name;
  final int? pts;
  final int? playerNo;
  final bool? isActive;

  LocalPlayer(
      {required this.name,
      required this.pts,
      required this.playerNo,
      this.isActive});

  LocalPlayer copyWith({String? name, int? pts, int? playerNo}) {
    return LocalPlayer(
      name: name ?? this.name,
      pts: pts ?? this.pts,
      playerNo: playerNo ?? this.playerNo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'pts': pts,
      'playerNo': playerNo,
      'isActive': isActive,
    };
  }

  factory LocalPlayer.fromMap(Map? fromSnapshot) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot!);
    return LocalPlayer(
        name: map['name'],
        pts: map['pts'],
        playerNo: map['playerNo'],
        isActive: map['isActive']);
  }

  String toJson() => json.encode(toMap());

  factory LocalPlayer.fromJson(String source) =>
      LocalPlayer.fromMap(json.decode(source));

  @override
  String toString() =>
      'LocalPlayer(name: $name, pts: $pts, playerNo: $playerNo, isActive : $isActive)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocalPlayer &&
        other.name == name &&
        other.pts == pts &&
        other.playerNo == playerNo &&
        other.isActive == isActive;
  }

  @override
  int get hashCode =>
      name.hashCode ^ pts.hashCode ^ playerNo.hashCode ^ isActive.hashCode;
}
