import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/board.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/models/localPlayer.dart';
import 'package:paricon/models/stats.dart';
import 'package:paricon/providers/prevStatsNotifier.dart';

import 'authProvider.dart';
import 'databaseProvider.dart';
import 'roomNotifierProvider.dart';
import 'roomProvider.dart';

final boardProvider = FutureProvider.autoDispose<Board>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.board;
  },
);

final iconProvider = StreamProvider.family.autoDispose<LocalIcon, String>(
  (ref, icon) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.localIcon(icon);
  },
);

final incrementPtsProvider = FutureProvider.autoDispose<bool>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    final player = ref.read(currentUserProvider);
    return boardDatabase.increment(player.uid);
  },
);

final currentIDProvider = StreamProvider.autoDispose<String>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.currentID;
  },
);

final nameProvider = FutureProvider.autoDispose<String>(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider);
    final String id = await ref.watch(currentIDProvider.last);

    return boardDatabase.playerName(id);
  },
);

final iconFoundProvider = FutureProvider.family.autoDispose<void, String>(
  (ref, icon) async {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return await boardDatabase.iconFound(icon);
  },
);

final localPlayerProvider =
    AutoDisposeStreamProviderFamily<LocalPlayer, String>(
  (ref, player) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.localPlayer(player);
  },
);

final btnClickProvider = AutoDisposeFutureProviderFamily<void, IconInfo>(
  (ref, iconInfo) async {
    final boardDatabase = ref.read(boardDatabaseProvider);
    final iconNotifier = ref.read(roomNotifierProvider);
    final firebaseUser = ref.read(currentUserProvider);

    await boardDatabase.setIconCheck(iconInfo.icon, true);
    bool check = iconNotifier.validateIcons(iconInfo);
    if (check == null) {
      return;
    }
    final id = iconInfo.icon;
    final id2 = iconNotifier.iconInfo.icon;
    iconNotifier.iconInfo = null;
    if (check) {
      await Future.wait(
        []
          ..addAll(
            [id, id2].map(
              (e) => boardDatabase.iconFound(e),
            ),
          )
          ..addAll(
            [
              boardDatabase.increment(firebaseUser.uid),
              boardDatabase.incrementIconsFound
            ],
          ),
      );
    } else {
      await Future.delayed(
        const Duration(milliseconds: 200),
        () => Future.wait(
          [
            ...[id, id2].map(
              (e) => boardDatabase.setIconCheck(e, false),
            ),
            ...[ref.read(checkNextPlayerProvider.future)],
          ],
        ),
      );
      //await ref.read(checkNextPlayerProvider.future);
    }
  },
);

final checkNextPlayerProvider = FutureProvider.autoDispose(
  (ref) async {
    final firebaseUser = ref.read(currentUserProvider);
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.boardPlayers.then(
      (fromSnapshot) {
        final map = Map<String, dynamic>.from(fromSnapshot);
        final sortMap = SplayTreeMap.from(
          map,
          (a, b) => map[a]["playerNo"].compareTo(map[b]["playerNo"]),
        );
        final List players = sortMap.keys.toList(growable: false);
        int yourNo = players.indexOf(firebaseUser.uid);
        yourNo++;
        if (yourNo == players.length) yourNo = 0;
        if (players[yourNo] != firebaseUser.uid) {
          boardDatabase.setCurrentID(players[yourNo]);
        }
      },
    );
  },
);

final iconsFoundProvider = StreamProvider.autoDispose<int>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider);
    return boardDatabase.sIconsFound;
  },
);

final updateStatsProvider = FutureProvider.autoDispose<bool>(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider);
    final firebaseUser = ref.read(currentUserProvider);
    final playerDatabase = ref.read(playerDatabaseProvider(firebaseUser.uid));

    final room = await ref.read(roomProvider.future);
    final Map fromSnapshot = await boardDatabase.boardPlayers;
    final Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);
    final sortMap = SplayTreeMap.from(
      map,
      (a, b) => map[b]["pts"].compareTo(map[a]["pts"]),
    );
    final int yourPts = sortMap[firebaseUser.uid]['pts'];
    final bool isWinner = sortMap.keys.first == firebaseUser.uid ||
        sortMap.values.first['pts'] == sortMap[firebaseUser.uid]['pts'];
    final bool isDraw =
        sortMap.values.first['pts'] == sortMap[firebaseUser.uid]['pts'];

    final String level = room.details.level;
    final int totalPts = iconCount(level) ~/ 2;

    final double _avg = (yourPts / totalPts) * 100;
    final double avg = double.parse(_avg.toStringAsFixed(2));

    final Stats stats = Stats(played: 1, win: isWinner ? 1 : 0, avg: avg);
    ref.read(prevStatsProvider).setStats(level, yourPts, avg, isWinner, isDraw);
    final bool isUpdated =
        await playerDatabase.updateStats(level.toLowerCase(), stats);
    return isUpdated;
  },
);

/*final leavingBoardProvider = FutureProvider.autoDispose(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider);
    final roomDatabase = ref.read(roomDatabaseProvider);
    //final firebaseUser = ref.read(currentUserProvider);

    final Map fromSnapshot = await boardDatabase.boardPlayers;
    final Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);
    if (map.length == 1) {
      Future.wait([boardDatabase.removeData, roomDatabase.removeData]);

      ref.watch(idNotifier.notifier).state = "";
    } else {
      //final String id = await ref.read(currentIDProvider.last);
      //await ref.read(checkNextPlayerProvider.future);

      //boardDatabase.leaveGame(firebaseUser.uid);
    }
  },
);*/

final allBoardPlayersProvider = FutureProvider.autoDispose<List<LocalPlayer>>(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider);
    final Map fromSnapshot = await boardDatabase.allBoardPlayers;
    final map = Map<String, dynamic>.from(fromSnapshot);
    final sortMap = SplayTreeMap.from(
      map,
      (a, b) => map[a]["playerNo"].compareTo(map[b]["playerNo"]),
    );
    final List players = sortMap.values
        .map((e) => LocalPlayer.fromMap(e))
        .toList(growable: false);
    return players;
  },
);

int iconCount(String level) {
  //16 or 30 for easy
  final String _level = level.toLowerCase();
  return _level == "easy"
      ? 16
      : _level == "medium"
          ? 42
          : 72;
}
