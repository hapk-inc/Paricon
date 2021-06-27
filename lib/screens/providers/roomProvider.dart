import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/localIcon.dart';
import '/models/room.dart';

import 'authProvider.dart';
import 'databaseProvider.dart';
import 'gameIconProvider.dart';
import 'roomIDProvider.dart';
import 'setGameProvider.dart';

final AutoDisposeFutureProvider<String>? createRoomProvider =
    FutureProvider.autoDispose<String>(
  (ref) async {
    final setGame = ref.read(setGameProvider);
    final roomDatabase = ref.read(roomDatabaseProvider!);
    final User user = ref.read(firebaseUserProvider!);

    final room = Room.createRoom(
        setGame.level, setGame.playerCount, user.uid, setGame.type);
    String key = await roomDatabase.createRoom(room);
    ref.read(idNotifier.notifier).state = key;
    return key;
  },
);

final AutoDisposeFutureProvider<Null> joinRoomProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider!);

    final user = ref.read(firebaseUserProvider!);
    await roomDatabase.joinRoom(user);
  },
);

final AutoDisposeFutureProvider<Room> roomProvider =
    FutureProvider.autoDispose<Room>(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider!);
    final room = await roomDatabase.room;
    ref.maintainState = false;
    return room;
  },
  name: 'roomProvider',
);

final AutoDisposeFutureProviderFamily<dynamic, String>? roomCheckProvider =
    FutureProvider.family.autoDispose<dynamic, String>(
  (ref, roomCode) async {
    final roomDatabase = ref.read(roomDatabaseProvider!);
    return await roomDatabase.checkRoom(roomCode).then(
      (id) {
        if (id is String) ref.read(idNotifier.notifier).state = id;

        return id;
      },
    );
  },
);

final AutoDisposeFutureProviderFamily<String, String>? creatorNameProvider =
    FutureProvider.autoDispose.family<String, String>(
  (ref, creatorID) async {
    final roomDatabase = ref.watch(roomDatabaseProvider!);
    return await roomDatabase.creatorName(creatorID);
  },
);

final AutoDisposeProvider<Query>? playersQueryProvider =
    Provider.autoDispose<Query>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider!);
    return roomDatabase.playersQuery;
  },
);

final AutoDisposeFutureProvider<bool> createBoardProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final room = ref.read(roomProvider).data!.value;
    final details = room.details;

    final Map playersProvider = await ref.read(roomPlayersProvider!.future);

    if (!kDebugMode) {
      if (playersProvider.length == 1) return false;
    }

    final boardDatabase = ref.read(boardDatabaseProvider!);

    final players = convertToBoard(playersProvider);

    final GameIconProvider xIcons = ref.read(gameIconProvider);
    final List<LocalIcon> localIcons = xIcons.generateIcons(details.level);
    final Map icons =
        localIcons.map((e) => e.toMap(xIcons.generateRandomID)).fold(
      {},
      (previousValue, element) => {...previousValue, ...element},
    );

    String _currentIcon = "";
    if (details.type == "orderWise") {
      final localIcon = localIcons[Random.secure().nextInt(localIcons.length)];
      _currentIcon = localIcon.iconCode;
      print("Current Icon is $_currentIcon");
    }

    final Map currentPlayer = {"currentID": players.keys.first};

    final Map map = {
      ...{"players": players},
      ...{"icons": icons},
      ...currentPlayer,
      ...{"type": details.type},
      if (_currentIcon.isNotEmpty) ...{"currentIcon": _currentIcon},
      //...{"iconsFound": 0},
    };
    await boardDatabase.createBoard(map);
    return true;
  },
);

Map convertToBoard(Map<dynamic, dynamic> map) {
  List<int> playerOrder = List.generate(map.length, (index) => index + 1)
    ..shuffle();

  List<String> colorNames = [
    'red',
    'green',
    'indigo',
    'brown',
    'purple',
    'orange',
    'blue',
    'pink'
  ]..shuffle();
  int i = 0;
  map.updateAll(
    (key, value) {
      Map<dynamic, dynamic> localPlayer = value;
      localPlayer.remove("timestamp");
      localPlayer["playerNo"] = playerOrder[i];
      localPlayer["color"] = colorNames[i];
      localPlayer["pts"] = 0;
      i++;
      return localPlayer;
    },
  );

  return map;
}

final AutoDisposeFutureProvider<Map<dynamic, dynamic>>? roomPlayersProvider =
    FutureProvider.autoDispose<Map>(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider!);
    return roomDatabase.roomPlayers;
  },
);

final AutoDisposeStreamProvider<bool>? sGameStartProvider =
    StreamProvider.autoDispose<bool>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider!);
    return roomDatabase.sGameStart;
  },
);

final AutoDisposeFutureProvider gameStartProvider = FutureProvider.autoDispose(
      (ref) async {
    try {
      final roomDatabase = ref.read(roomDatabaseProvider!);
      await roomDatabase.gameStart(true);
    } catch (e) {}
  },
);

final leavingRoomProvider = FutureProvider.autoDispose(
      (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider!);
    final firebaseUser = ref.read(firebaseUserProvider!);

    final room = await ref.read(roomProvider.future);
    final Map playersProvider = await ref.read(roomPlayersProvider!.future);

    if (room.details.creatorID == firebaseUser.uid) {
      if (playersProvider.length == 1)
        await roomDatabase.removeData;
      else
        Future.wait(
          [
            ref.read(changeCreatorProvider.future),
            roomDatabase.leaveRoom(firebaseUser.uid)
          ],
        );
    } else
      roomDatabase.leaveRoom(firebaseUser.uid);
  },
);

final AutoDisposeFutureProvider changeCreatorProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider!);
    final firebaseUser = ref.read(firebaseUserProvider!);

    final Map playersProvider = await ref.read(roomPlayersProvider!.future);
    List<String> players = List.from(playersProvider.keys);
    String nCreator =
        players.firstWhere((element) => element != firebaseUser.uid);
    //String nCreator = players[Random.secure().nextInt(players.length)];
    await roomDatabase.newCreator(nCreator);
  },
);

final AutoDisposeStreamProvider<String>? creatorIDProvider =
    StreamProvider.autoDispose<String>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider!);
    return roomDatabase.sCreatorID;
  },
);
