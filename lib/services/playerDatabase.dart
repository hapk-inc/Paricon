import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:paricon/models/playerMeta.dart';

import '/models/profile.dart';
import '/models/stats.dart';
import 'database.dart';

class PlayerDatabase extends MyDatabase {
  final String? uid;

  PlayerDatabase(FirebaseApp app, {this.uid}) : super(app);

  @override
  // TODO: implement playerRef
  DatabaseReference get playerRef => uid == null || uid!.isEmpty
      ? super.playerRef
      : super.playerRef.child(uid!);

  DatabaseReference get profileRef => playerRef.child('profile');

  DatabaseReference get metadataRef => playerRef.child('metadata');

  Future<Profile> get profile => profileRef.once().then(
        (snapshot) => Profile.fromMap(snapshot.value),
      );

  Future get deleteUser => playerRef.remove();

  Future createPlayer(User user) async {
    final num playerID =
        10000000 + Random.secure().nextInt(99999999 - 10000000);
    await playerRef.child(user.uid).child("profile").set(
      {
        "name": user.displayName,
        "userID": playerID,
        "stats": {
          "easy": Stats.toZero(),
          "medium": Stats.toZero(),
          "hard": Stats.toZero(),
        }
      },
    );
  }

  Future<bool> updateStats(String level, Stats stats) async {
    final DatabaseReference _ref =
        playerRef.child('profile').child("stats").child(level);
    final TransactionResult transactionResult = await _ref.runTransaction(
      (MutableData mutableData) async {
        Map map = mutableData.value ?? null;
        Stats oldStats = Stats.fromMap(map);
        Stats newStats = oldStats + stats;
        mutableData.value = newStats.toMap();

        return mutableData;
      },
    );
    return transactionResult.committed;
  }

  Future<void> updateName(String? newName) async =>
      profileRef.child("name").set(newName);

  Future<String?> fetchPrevRecord(String level) async =>
      profileRef.child("stats").child(level).child("timeRecord").once().then(
        (value) {
          return value.value as String;
        },
      ).onError((error, _) => "");

  Future<List<Profile>?> allPlayers(String level) async => playerRef
          .orderByChild("profile/stats/$level/played")
          .startAt(kDebugMode
              ? 5
              : level == "easy"
                  ? 5
                  : 10)
          //.limitToLast(10)
          .once()
          .then(
        (snapshot) {
          if (snapshot.value == null) return null;
          final Map map = snapshot.value;

          List<Profile> _list = map.values
              .map(
                (e) => Profile.fromMap(e['profile']),
              )
              .toList(growable: false);

          return _list.reversed.toList();
        },
      );

  Future<bool> get updateMetaData async {
    //final DatabaseReference _ref = metadataRef;
    final TransactionResult transactionResult =
        await metadataRef.runTransaction((mutableData) async {
      if (mutableData.value == null) {
        mutableData.value = PlayerMetaData(currentTime: DateTime.now()).toMap();
      } else {
        final Map map = mutableData.value;
        final PlayerMetaData metaData = PlayerMetaData.fromMap(map);
        mutableData.value = metaData.updateNow().toMap();
      }
      return mutableData;
    });
    return transactionResult.committed;
  }

  /*Future<bool> get tournamentPlayed async {
    final DatabaseReference _ref = metadataRef.child("lastTournamentPlayed");
    final TransactionResult result = await _ref.runTransaction(
      (mutableData) async {
        if (mutableData.value == null) {
          mutableData.value = DateTime.now().toIso8601String();
          return mutableData;
        } else {
          final DateTime prevDateTime = DateTime.parse(mutableData.value);
          final DateTime now = DateTime.now();
          Duration diff = now.difference(prevDateTime);
          if (diff.inMinutes < 30) {
            mutableData.value = DateTime.now().toIso8601String();
          }
          return mutableData;
        }
      },
    );
    return result.committed;
  }*/

  Future get updateTournamentPlayed => metadataRef
      .child("lastTournamentPlayed")
      .set(DateTime.now().toIso8601String());

  Future<Duration?> get checkTournamentPlayed =>
      metadataRef.child("lastTournamentPlayed").once().then(
        (snapshot) async {
          if (snapshot.value == null) return null;
          final DateTime prevDateTime = DateTime.parse(snapshot.value);
          final DateTime now = DateTime.now();
          Duration diff = now.difference(prevDateTime);
          return diff;
        },
      );
}
