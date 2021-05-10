import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/room.dart';

import 'authProvider.dart';
import 'databaseProvider.dart';
import 'iconProvider.dart';
import 'roomIDProvider.dart';
import 'setGameProvider.dart';

final createRoomProvider = FutureProvider.autoDispose<String>(
  (ref) async {
    final setGame = ref.read(setGameProvider);
    final roomDatabase = ref.watch(roomDatabaseProvider);
    final User user = ref.read(currentUserProvider);

    final room = Room.createRoom(setGame.level, setGame.playerCount, user.uid);
    print("19-" + room.toJson());
    String key = await roomDatabase.createRoom(room);
    ref.watch(idNotifier.notifier).state = key;
    return key;
  },
);

final joinRoomProvider = FutureProvider.autoDispose((ref) async {
  final roomDatabase = ref.read(roomDatabaseProvider);

  final user = ref.read(currentUserProvider);
  await roomDatabase.joinRoom(user);
});

final roomProvider = FutureProvider.autoDispose<Room>(
  (ref) async {
    final roomDatabase = ref.watch(roomDatabaseProvider);
    final Room room = await roomDatabase.room;
    return room;
  },
  name: 'roomProvider',
);

final roomCheckProvider = FutureProvider.family.autoDispose<String, String>(
  (ref, roomCode) async {
    final roomDatabase = ref.read(roomDatabaseProvider);
    //final roomNotifier = ref.watch(roomNotifierProvider);
    //roomNotifier.loading = true;
    return await roomDatabase.checkRoom(roomCode).then(
      (id) {
        ref.watch(idNotifier.notifier).state = id;
        return id;
      },
    );
  },
);

final creatorNameProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, creatorID) async {
    final roomDatabase = ref.watch(roomDatabaseProvider);
    return await roomDatabase.creatorName(creatorID);
  },
);

final playersQueryProvider = Provider.autoDispose<Query>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.playersQuery;
  },
);

final createBoardProvider = FutureProvider.autoDispose(
  (ref) async {
    final room = ref.read(roomProvider).data.value;
    final Map playersProvider = await ref.watch(roomPlayersProvider.future);

    final boardDatabase = ref.read(boardDatabaseProvider);

    final players = convertToBoard(playersProvider);

    final Icons xIcons = ref.read(iconProvider);
    final Map icons = xIcons
        .generateIcons(room.details.level)
        .map((e) => e.toMap(xIcons.generateRandomID))
        .fold({}, (previousValue, element) => {...previousValue, ...element});

    final Map currentPlayer = {"currentID": room.details.creatorID};

    final Map map = {
      ...{"players": players},
      ...{"icons": icons},
      ...currentPlayer,
      ...{"iconsFound": 0},
    };

    print("81-" + map.toString());
    await boardDatabase.createBoard(map);
  },
);

Map convertToBoard(Map<dynamic, dynamic> map) {
  int i = 0;
  map.updateAll((key, value) {
    i++;
    Map<dynamic, dynamic> localPlayer = value;
    localPlayer.remove("timestamp");
    localPlayer["playerNo"] = i;
    localPlayer["pts"] = 0;
    return localPlayer;
  });
  return map;
}

final roomPlayersProvider = FutureProvider.autoDispose<Map>(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.roomPlayers;
  },
);

final sGameStartProvider = StreamProvider.autoDispose<bool>(
  (ref) {
    final roomDatabase = ref.read(roomDatabaseProvider);
    return roomDatabase.sGameStart;
  },
);

final gameStartProvider = FutureProvider.autoDispose(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider);
    await roomDatabase.gameStart(true);
  },
);

final leavingRoomProvider = FutureProvider.autoDispose<bool>(
  (ref) async {
    final roomDatabase = ref.read(roomDatabaseProvider);
    final firebaseUser = ref.read(currentUserProvider);

    final room = ref.read(roomProvider).data.value;
    if (room.details.creatorID == firebaseUser.uid) {
      await roomDatabase.removeData;
    } else {
      await roomDatabase.leaveRoom(firebaseUser.uid);
    }
    ref.read(idNotifier.notifier).empty();
    return room.details.creatorID == firebaseUser.uid;
  },
);
