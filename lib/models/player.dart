import 'dart:convert';

import 'package:meta/meta.dart';

import 'profile.dart';

class Player {
  Profile profile;
  Player({
    @required this.profile,
  });

  Map<String, dynamic> toMap() {
    return {
      'profile': profile.toMap(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      profile: Profile.fromMap(map['profile']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Player.fromJson(String source) => Player.fromMap(json.decode(source));

  @override
  String toString() => 'Player(profile: $profile)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Player && other.profile == profile;
  }

  @override
  int get hashCode => profile.hashCode;
}
