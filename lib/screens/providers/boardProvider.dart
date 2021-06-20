import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/board.dart';
import 'package:paricon/models/enumFiles.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/models/localPlayer.dart';
import 'package:paricon/models/stats.dart';
import 'package:paricon/screens/common/durationCount.dart';
import 'package:paricon/screens/providers/onlineBoardProvider.dart';

import 'authProvider.dart';
import 'databaseProvider.dart';

final AutoDisposeFutureProvider<Board> boardProvider =
    FutureProvider.autoDispose<Board>(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    return boardDatabase.board;
  },
);

final AutoDisposeStreamProviderFamily<LocalIcon, String> iconProvider =
    StreamProvider.family.autoDispose<LocalIcon, String>(
  (ref, icon) {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    return boardDatabase.localIcon(icon);
  },
);

/*final AutoDisposeFutureProvider<bool>? incrementPtsProvider =
    FutureProvider.autoDispose<bool>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    final player = ref.read(firebaseUserProvider!);
    return boardDatabase.increment(player.uid);
  },
);*/

final AutoDisposeStreamProvider<String> currentIDProvider =
    StreamProvider.autoDispose<String>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    return boardDatabase.currentID;
  },
);

final AutoDisposeStreamProvider<String> currentIconProvider =
    StreamProvider.autoDispose<String>(
  (ref) {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    return boardDatabase.currentIcon;
  },
);

/*final AutoDisposeFutureProvider<String>? nameProvider =
    FutureProvider.autoDispose<String>(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    final String id = await ref.watch(currentIDProvider.last);

    return boardDatabase.playerName(id);
  },
);*/

/*final AutoDisposeFutureProviderFamily<void, String>? iconFoundProvider =
    FutureProvider.family.autoDispose<void, String>(
  (ref, icon) async {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    return await boardDatabase.iconFound(icon);
  },
);*/

final localPlayerProvider =
    AutoDisposeStreamProviderFamily<LocalPlayer, String>(
  (ref, player) {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    return boardDatabase.localPlayer(player);
  },
);

final btnClickProvider = FutureProvider.family.autoDispose<bool, String>(
  (ref, _icon) async {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    final notifier = ref.read(onlineBoardNotifier);
    //final boardNotifier = ref.read(onlineBoardNotifier);
    final firebaseUser = ref.read(firebaseUserProvider!);

    final board = ref.read(boardProvider).data!.value;
    final iconsID = board.icons;

    final String color = notifier.myPlayer!.color;

    await boardDatabase.setIconCheck(_icon, true);
    notifier.alreadyClicked = !notifier.alreadyClicked;

    if (!notifier.alreadyClicked) {
      final List<LocalIcon> selectedIcons = notifier.icons
          .where((element) => element.isCheck && !element.isFound)
          .toList(growable: false);

      if (selectedIcons.length == 2) {
        final bool sameIcons =
            selectedIcons.first.checkIconCode(selectedIcons.last);
        bool _validate = false;

        if (notifier.type == GameType.orderWise) {
          if (sameIcons) {
            final String orderWiseIcon =
                await ref.read(currentIconProvider.last);
            if (orderWiseIcon.isEmpty) {
              _validate = sameIcons;
            } else {
              _validate = selectedIcons.first.iconCode == orderWiseIcon;
            }
          } else {
            _validate = false;
          }
        } else {
          _validate = sameIcons;
        }

        if (_validate) {
          await boardDatabase.increment(firebaseUser.uid);

          await Future.wait(
            selectedIcons.map(
              (e) {
                final updatedIcon =
                    e.copyWith(color: color, isFound: true, isCheck: false);
                return boardDatabase.updateIcon(
                    iconsID[e.iconNo! - 1], updatedIcon);
              },
            ),
          );

          if (notifier.type == GameType.orderWise) {
            if (notifier.orderWiseIcon) {
              await boardDatabase.setCurrentIcon("");
              notifier.orderWiseIcon = false;
            }
          }
        } else {
          final List<int> iconOrder = selectedIcons.map(
            (e) {
              final int i = e.iconNo! - 1;
              return i;
            },
          ).toList(growable: false);
          await Future.delayed(
            DurationCount.m500,
            () => Future.wait(
              iconOrder.map(
                (e) => boardDatabase.setIconCheck(iconsID[e], false),
              ),
            ),
          );
          if (notifier.type == GameType.orderWise) {
            if (!notifier.orderWiseIcon) {
              final List<LocalIcon> falseIcons = notifier.icons
                  .where((element) => !element.isCheck && !element.isFound)
                  .toList(growable: false);
              final String newOrderWiseIcon =
                  falseIcons[Random.secure().nextInt(falseIcons.length)]
                      .iconCode;
              await boardDatabase.setCurrentIcon(newOrderWiseIcon);
              notifier.orderWiseIcon = true;
            }
          }
          await ref.read(nextPlayerProvider.future);
        }
      }
      return true;
    } else
      return false;

    //if(!boar)
  },
);

final AutoDisposeFutureProvider nextPlayerProvider = FutureProvider.autoDispose(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    final boardNotifier = ref.read(onlineBoardNotifier);
    final firebaseUser = ref.read(firebaseUserProvider!);

    final board = ref.read(boardProvider).data!.value;
    final List<String> playersID = List.castFrom(board.players);
    final players = boardNotifier.players;
    if (players.length != 1) {
      int i = boardNotifier.currentIndex.toInt();
      do {
        i++;
        if (i == players.length) i = 0;
      } while (!players[i.toInt()].isActive);
      if (playersID[i] != firebaseUser.uid)
        await boardDatabase.setCurrentID(playersID[i]);
    }
  },
);

/*final AutoDisposeFutureProvider<Null>? checkNextPlayerProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final firebaseUser = ref.read(firebaseUserProvider!);
    final boardDatabase = ref.read(boardDatabaseProvider!);
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
      } /*as FutureOr<Never> Function(dynamic)*/,
    );
  } /*as Future<Never> Function(AutoDisposeProviderReference)*/,
);*/

/*final AutoDisposeStreamProvider<int>? allIconsFoundProvider =
    StreamProvider.autoDispose<int>(
  (ref) {
    try {
      final boardDatabase = ref.read(boardDatabaseProvider!);
      return boardDatabase.sIconsFound;
    } catch (e) {
      return Stream.error(e);
    }
  },
);*/

final AutoDisposeFutureProvider updateStatsProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final firebaseUser = ref.read(firebaseUserProvider!);
    final playerDatabase = ref.read(playerDatabaseProvider!(firebaseUser.uid));

    final notifier = ref.read(onlineBoardNotifier);

    final List<LocalPlayer> sortedPlayers = notifier.sortByPoints;
    final bool isWinner = sortedPlayers.first.pts == notifier.myPlayer!.pts;

    final Stats stats =
        Stats(played: 1, win: isWinner ? 1 : 0, avg: notifier.myAvg);
    await playerDatabase.updateStats(notifier.level, stats);
  },
);
/*final AutoDisposeFutureProvider<bool>? updateStatsProvider =
    FutureProvider.autoDispose<bool>(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    final firebaseUser = ref.read(firebaseUserProvider!);
    final playerDatabase = ref.read(playerDatabaseProvider!(firebaseUser.uid));
    final gameIcon = ref.read(gameIconProvider!);
    final room = await ref.read(roomProvider!.future);
    final Map fromSnapshot = await (boardDatabase.boardPlayers);
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

    final String level = room.details.level!;
    final int totalPts = gameIcon.iconCount(level) ~/ 2;

    final double _avg = (yourPts / totalPts) * 100;
    final double avg = double.parse(_avg.toStringAsFixed(2));

    final Stats stats = Stats(played: 1, win: isWinner ? 1 : 0, avg: avg);
    ref.read(prevStatsProvider).setStats(level, yourPts, avg, isWinner, isDraw);
    final bool isUpdated =
        await playerDatabase.updateStats(level.toLowerCase(), stats);
    return isUpdated;
  },
);*/

/*final leavingBoardProvider = FutureProvider.autoDispose(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    final roomDatabase = ref.read(roomDatabaseProvider!);

    final Map fromSnapshot = await boardDatabase.boardPlayers;
    final Map<String, dynamic> map = Map<String, dynamic>.from(fromSnapshot);
    if (map.length == 1) {
      Future.wait([boardDatabase.removeData, roomDatabase.removeData]);

      ref.watch(idNotifier.notifier).state = "";
    } else {
      final String id = await ref.read(currentIDProvider.last);
      final firebaseUser = ref.read(firebaseUserProvider!);
      if (firebaseUser.uid == id)
        await ref.read(checkNextPlayerProvider!.future);

      boardDatabase.leaveGame(firebaseUser.uid);
    }
  },
);*/

/*final AutoDisposeFutureProvider<List<LocalPlayer>>? allBoardPlayersProvider =
    FutureProvider.autoDispose<List<LocalPlayer>>(
  (ref) async {
    final boardDatabase = ref.read(boardDatabaseProvider!);
    final Map fromSnapshot = await (boardDatabase.allBoardPlayers);
    final map = Map<String, dynamic>.from(fromSnapshot);
    final sortMap = SplayTreeMap.from(
      map,
      (a, b) => map[a]["playerNo"].compareTo(map[b]["playerNo"]),
    );
    final List players = sortMap.values
        .map((e) => LocalPlayer.fromMap(e))
        .toList(growable: false);
    return players as FutureOr<List<LocalPlayer>>;
  },
);*/

/*final AutoDisposeFutureProvider<String> yourColorProvider =
    AutoDisposeFutureProvider<String>(
  (ref) async {
    final firebaseUser = ref.read(firebaseUserProvider!);
    final boardDatabase = ref.read(boardDatabaseProvider!);
    return boardDatabase.playerColor(firebaseUser.uid);
  },
);

final AutoDisposeFutureProvider<String> currentPlayerColor =
    AutoDisposeFutureProvider<String>(
  (ref) async {
    final currentPlayer = await ref.watch(currentIDProvider.last);
    final boardDatabase = ref.read(boardDatabaseProvider!);
    return boardDatabase.playerColor(currentPlayer);
  },
);
*/
