import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:paricon/models/enumFiles.dart';
import 'package:paricon/models/room.dart';
import 'package:rxdart/rxdart.dart';

import 'database.dart';

class RoomDatabase extends MyDatabase {
  final String? id;

  RoomDatabase(FirebaseApp app, {this.id}) : super(app);

  @override
  DatabaseReference get roomRef =>
      id!.isEmpty ? super.roomRef : super.roomRef.child(id!);

  DatabaseReference get roomPlayersRef => roomRef.child('players');

  DatabaseReference get roomDetailsRef => roomRef.child('details');

  DatabaseReference get gameStartRef => roomRef.child('isGameStarted');

  DatabaseReference get creatorRef => roomDetailsRef.child("creatorID");

  Future<String> creatorName(String uid) async => await roomPlayersRef
      .child(uid)
      .child('name')
      .once()
      .then((snapshot) => snapshot.value as String);

  Future<String> createRoom(Room room) async {
    String _key = roomRef.push().key;

    await roomRef.child(_key).set(room.toMap());
    return _key;
  }

  Future joinRoom(User user) async {
    Map map = {
      "isActive": true,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "name": user.displayName ?? "SomeOne",
    };

    await roomPlayersRef.child(user.uid).set(map);
  }

  Future<Room> get room {
    return roomRef.once().then(
      (snapshot) {
        Room _room = Room.fromMap(snapshot.value);
        return _room;
      },
      //onError: (e) => print(e),
    );
  }

  Query get playersQuery =>
      roomPlayersRef.orderByChild("isActive").equalTo(true);

  Future<Map> get roomPlayers => playersQuery.once().then(
        (snapshot) {
          Map map = snapshot.value;
          return map;
        },
      );

  Future leaveRoom(String uid) async {
    DatabaseReference leavingPlayerRef = roomPlayersRef.child(uid);
    await leavingPlayerRef.child("isActive").set(false);
    await leavingPlayerRef.remove();
  }

  Future gameStart(bool value) => gameStartRef.set(value);

  Stream<bool> get sGameStart {
    late StreamController<bool> controller;
    controller = StreamController<bool>(
      onListen: () => gameStartRef.onValue.listen(
        (event) {
          var check = event.snapshot.value;
          if (check is bool) {
            controller.add(check);
            if (check) controller.close();
          }
        },
      ),
    );
    return controller.stream;
  }

  Stream<String> get sCreatorID {
    late BehaviorSubject<String> controller;
    controller = BehaviorSubject<String>(
      onListen: () => creatorRef.onValue.listen(
        (event) {
          final id = event.snapshot.value;
          if (id is String)
            controller.add(id);
          else {
            if (controller.hasValue) controller.close();
          }
        },
      ),
    );
    return controller.stream;
  }

  Future get removeData => roomRef.remove();

  Future<ValidateRoom> checkRoom(String roomCode, String user) async {
    num _roomCode = num.parse(roomCode);
    return roomRef
        .orderByChild("details/roomCode")
        .equalTo(_roomCode)
        .once()
        .then(
      (snapshot) {
        if (snapshot.value == null)
          return ValidateRoom(status: RoomStatus.notExists);
        final Map map = snapshot.value;
        if (map.length != 1)
          return ValidateRoom(status: RoomStatus.duplicateCode);
        final Room room = Room.fromMap(map.values.first);
        if (room.details.maxCount < room.players!.length)
          return ValidateRoom(status: RoomStatus.houseFull);
        if (room.isGameStarted) {
          return ValidateRoom(
            status: RoomStatus.alreadyStarted,
            id: map.keys.first,
            alreadyIn: room.players!.any((element) => element == user),
          );
        }

        return ValidateRoom(status: RoomStatus.available, id: map.keys.first);
      },
    );
  }

  Future newCreator(String nCreator) => creatorRef.set(nCreator);
}
