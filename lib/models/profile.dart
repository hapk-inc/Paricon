import 'dart:convert';

import 'package:collection/collection.dart';

import 'stats.dart';

class Profile {
  String name;
  int? userID;
  List<Stats>? stats;

  Profile({required this.name, this.userID, this.stats});

  Profile copyWith({String? name, int? userID, List<Stats>? stats}) => Profile(
        name: name ?? this.name,
        userID: userID ?? this.userID,
        stats: stats ?? this.stats,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'userID': userID,
        'stats': stats!.map((x) => x.toMap()).toList(growable: false),
      };

  factory Profile.fromMap(Map fromSnapshot) {
    Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);

    final profile = Profile(
      name: map['name'],
      userID: map['userID'],
      stats: List.from(
        const ['easy', 'medium', 'hard'].map(
          (e) => Stats.fromMap(map['stats'][e]),
        ),
      ),
    );

    return profile;
  }

  factory Profile.onlyName(Map fromSnapshot) {
    Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);

    final profile = Profile(name: map['name']);

    return profile;
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source));

  @override
  String toString() => 'Profile(name: $name, userID: $userID, stats: $stats)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is Profile &&
        other.name == name &&
        other.userID == userID &&
        listEquals(other.stats, stats);
  }

  @override
  int get hashCode => name.hashCode ^ userID.hashCode ^ stats.hashCode;
}
