import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'stats.dart';

class Profile {
  String name;
  int userID;
  List<Stats> stats;

  Profile({@required this.name, @required this.userID, @required this.stats});

  Profile copyWith({String name, int userID, List<Stats> stats}) => Profile(
        name: name ?? this.name,
        userID: userID ?? this.userID,
        stats: stats ?? this.stats,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'userID': userID,
        'stats': stats?.map((x) => x.toMap())?.toList(growable: false),
      };

  factory Profile.fromMap(Map fromSnapshot) {
    Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);

    return Profile(
      name: map['name'],
      userID: map['userID'] ?? null,
      stats: map['stats'] == null
          ? null
          : List.from(
              const ['easy', 'medium', 'hard'].map(
                (e) => Stats.fromMap(map['stats'][e]),
              ),
            ),
    );
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
