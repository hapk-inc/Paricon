import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:paricon/models/board.dart';
import 'package:paricon/models/localIcon.dart';
import 'package:paricon/models/localPlayer.dart';
import 'package:rxdart/rxdart.dart';

import 'database.dart';

class BoardDatabase extends MyDatabase {
  final String? id;

  BoardDatabase(FirebaseApp app, {this.id}) : super(app);

  @override
  DatabaseReference get boardRef => super.boardRef.child(id!);

  DatabaseReference get boardIconRef => boardRef.child("icons");

  DatabaseReference get boardPlayerRef => boardRef.child("players");

  DatabaseReference get boardCurrentIdRef => boardRef.child("currentID");

  DatabaseReference get boardIconsFoundRef => boardRef.child("iconsFound");

  Future createBoard(Map board) async => await boardRef.set(board);

  Future<Board> get board async => await boardRef.once().then(
        (snapshot) => Board.fromMap(snapshot.value),
      );

  Future get removeData => boardRef.remove();

  Stream<String> get currentID {
    late BehaviorSubject<String> subject;

    subject = BehaviorSubject(
      onListen: () => boardCurrentIdRef.onValue.listen(
        (event) {
          String? e = event.snapshot.value ?? null;
          if (e == null && subject.hasValue)
            subject.close();
          else
            subject.add(e!);
        },
      ),
    );
    return subject.stream;
  }

  Stream<LocalIcon> localIcon(String icon) {
    late StreamController<LocalIcon> controller;
    controller = StreamController<LocalIcon>(
      onListen: () => boardIconRef.child(icon).onValue.listen((event) {
        var value = event.snapshot.value;
        if (value != null) {
          LocalIcon localIcon = LocalIcon.fromMap(value);
          controller.add(localIcon);
          if (localIcon.isFound!) {
            controller.close();
          }
        }
      }),
    );
    return controller.stream;
  }

  Future<bool> increment(String player) async {
    // Increment counter in transaction.
    DatabaseReference _ref = boardPlayerRef.child(player).child("pts");
    final TransactionResult transactionResult = await _ref.runTransaction(
      (MutableData mutableData) async {
        mutableData.value = (mutableData.value ?? 0) + 1;
        return mutableData;
      },
    );
    return transactionResult.committed;
  }

  Future<bool> get incrementIconsFound async {
    // Increment counter in transaction.
    final TransactionResult transactionResult =
        await boardIconsFoundRef.runTransaction(
      (MutableData mutableData) async {
        mutableData.value = (mutableData.value ?? 0) + 2;
        return mutableData;
      },
    );
    return transactionResult.committed;
  }

  Future get boardPlayers => boardPlayerRef
      .orderByChild("isActive")
      .equalTo(true)
      .once()
      .then((snapshot) => snapshot.value);

  Future get allBoardPlayers =>
      boardPlayerRef.once().then((snapshot) => snapshot.value);

  Future<String> playerName(String player) => boardPlayerRef
      .child(player)
      .child("name")
      .once()
      .then((snapShot) => snapShot.value);

  Future setIconCheck(String icon, bool check) =>
      boardIconRef.child(icon).child("isCheck").set(check);

  Future iconFound(String icon) =>
      boardIconRef.child(icon).child("isFound").set(true);

  Stream<LocalPlayer> localPlayer(String player) {
    late BehaviorSubject<LocalPlayer> subject;
    subject = BehaviorSubject<LocalPlayer>(
      onListen: () => boardPlayerRef.child(player).onValue.listen(
        (event) {
          final LocalPlayer? player = LocalPlayer.fromMap(event.snapshot.value);
          if (player == null && subject.hasValue)
            subject.close();
          else
            subject.add(player!);
        },
      ),
    );
    return subject.stream;
  }

  Future setCurrentID(String player) => boardCurrentIdRef.set(player);

  Future leaveGame(String uid) async =>
      boardPlayerRef.child(uid).child("isActive").set(false);

  Stream<int> get sIconsFound {
    late BehaviorSubject<int> subject;
    subject = BehaviorSubject(
      onListen: () => boardIconsFoundRef.onValue.listen(
        (event) {
          int e = event.snapshot.value;
          if (e == null && subject.hasValue)
            subject.close();
          else
            subject.add(e);
        },
      ),
    );
    return subject.stream;
  }
}
