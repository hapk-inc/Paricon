import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:paricon/models/playerMeta.dart';

import '/models/profile.dart';
import '/models/stats.dart';
import 'database.dart';

class PlayerDatabase extends MyDatabase {
  final String? uid;

  PlayerDatabase(FirebaseApp app, {this.uid}) : super(app);

  //final String _today = DateFormat.yMMMd().format(DateTime.now());
  final String _today = DateFormat.yMMMd().format(DateTime.now());

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
              ? 0
              : level == "easy"
                  ? 2
                  : 5)
          //.limitToLast(10)
          .once()
          .then(
        (snapshot) {
          if (snapshot.value == null) return null;
          final Map map = snapshot.value;
          //print('PD-96 $map');
          map.removeWhere(
            (key, value) {
              if (value['metadata'] == null) return true;
              PlayerMetaData metaData =
                  PlayerMetaData.fromMap(value['metadata']);
              //print(' PD-182 ${metaData.currentTime}');
              return metaData.currentTime.month != DateTime.now().month;
            },
          );
          List<Profile> _list = map.values
              .map(
                (e) => Profile.fromMap(e['profile']),
              )
              .toList(growable: false);

          return _list.reversed.toList();
        },
      );

  Future<bool> updateMetaData({User? user}) async {
    late bool _a;

    final TransactionResult transactionResult =
        await metadataRef.runTransaction((mutableData) async {
      if (mutableData.value == null) {
        mutableData.value = PlayerMetaData(currentTime: DateTime.now()).toMap();

        _a = user!.metadata.creationTime!.month != DateTime.now().month;
        //if()
      } else {
        final Map map = mutableData.value;
        final PlayerMetaData metaData = PlayerMetaData.fromMap(map);
        final newMetaData = metaData.updateNow();

        if (kDebugMode) {
          _a = newMetaData.currentTime.month != DateTime.august;
        } else {
          _a = newMetaData.currentTime.month != newMetaData.lastOpened!.month;
        }

        mutableData.value = newMetaData.toMap();
      }
      return mutableData;
    });
    if (transactionResult.committed)
      return _a;
    else
      return false;
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

  Future updatePrevStats(String level) async {
    final _ref = profileRef.child('stats/$level');
    _ref.runTransaction(
      (mutableData) async {
        Map map = mutableData.value ?? null;
        //print('PD-175 $map');

        Stats stats = Stats.fromMap(map);
        if (stats.prevStats == null) {
          final f = {
            ...Stats.toZero(),
            ...{
              'prevStats': {_today: "${stats.played}-${stats.win}-${stats.avg}"}
            }
          };
          //print('PD-185, $f');
          mutableData.value = f;
        } else {
          stats.prevStats![_today] =
              "${stats.played}-${stats.win}-${stats.avg}";
          mutableData.value = {
            ...Stats.toZero(),
            ...{'prevStats': stats.prevStats!},
          };
        }

        return mutableData;
      },
    );
/* final Map map = {
      ...{"players": players},
      ...{"icons": icons},
      ...currentPlayer,
      ...{"type": details.type},
      if (_currentIcon.isNotEmpty) ...{"currentIcon": _currentIcon},
      //...{"iconsFound": 0},
    };*/
    /*   final DatabaseReference _ref =
        playerRef.child('profile').child("stats").child(level);
    final TransactionResult transactionResult = await _ref.runTransaction(
      (MutableData mutableData) async {
        Map map = mutableData.value ?? null;
        Stats oldStats = Stats.fromMap(map);
        Stats newStats = oldStats + stats;
        mutableData.value = newStats.toMap();

        return mutableData;
      },
    );*/
  }
}
