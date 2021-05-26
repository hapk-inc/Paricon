import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:paricon/models/profile.dart';
import 'package:paricon/models/stats.dart';

import 'database.dart';

class PlayerDatabase extends MyDatabase {
  final String? uid;
  PlayerDatabase(FirebaseApp app, {this.uid}) : super(app);

  @override
  // TODO: implement playerRef
  DatabaseReference get playerRef =>
      uid == null ? super.playerRef : super.playerRef.child(uid!);

  DatabaseReference get profileRef => playerRef.child('profile');

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
        try {
          Map map = mutableData.value ?? null;
          Stats oldStats = Stats.fromMap(map);
          Stats newStats = oldStats + stats;
          mutableData.value = newStats.toMap();
        } catch (e) {}

        return mutableData;
      },
    );
    return transactionResult.committed;
  }
}
