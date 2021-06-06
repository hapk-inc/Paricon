class LocalPlayer {
  final String? name;
  final String? color;
  int? pts;
  final int? playerNo;
  final bool? isActive;

  LocalPlayer({
    required this.name,
    required this.color,
    required this.pts,
    required this.playerNo,
    this.isActive,
  });

  LocalPlayer copyWith({String? name, int? pts, int? playerNo}) {
    return LocalPlayer(
      name: name ?? this.name,
      pts: pts ?? this.pts,
      playerNo: playerNo ?? this.playerNo,
      color: color ?? this.color,
    );
  }

  factory LocalPlayer.fromMap(Map? fromSnapshot) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot!);
    return LocalPlayer(
        name: map['name'],
        pts: map['pts'],
        color: map['color'] ?? null,
        playerNo: map['playerNo'],
        isActive: map['isActive']);
  }

  @override
  String toString() =>
      'LocalPlayer(name: $name, pts: $pts, playerNo: $playerNo, isActive : $isActive)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocalPlayer &&
        other.name == name &&
        other.pts == pts &&
        other.color == color &&
        other.playerNo == playerNo &&
        other.isActive == isActive;
  }

  @override
  int get hashCode =>
      name.hashCode ^ pts.hashCode ^ playerNo.hashCode ^ isActive.hashCode;
}
