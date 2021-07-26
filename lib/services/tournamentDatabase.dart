import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:paricon/models/tournament.dart';
import 'package:rxdart/rxdart.dart';

import 'database.dart';

class TournamentDatabase extends MyDatabase {
  final String? uid;
  TournamentDatabase(FirebaseApp app, {this.uid}) : super(app);

  final String _today = DateFormat.yMMMd().format(DateTime.now());

  DatabaseReference get tournamentPlayerRef => super
      .tournamentRef
      .child("participants/$uid")
      .orderByChild("date")
      .equalTo(_today)
      .reference();

  DatabaseReference get todayWinnerRef =>
      super.tournamentRef.child("todayWinner").child(_today);

  DatabaseReference get allTimeRecordRef =>
      super.tournamentRef.child("allTimeRecord");

  Query get participantsQuery => super
      .tournamentRef
      .child("participants")
      .orderByChild("date")
      .equalTo(_today);

  Stream<List<Participant>> get participants => participantsQuery.onValue.map(
        (event) {
          final Map map = event.snapshot.value;
          List<Participant> _list = map.values
              .map(
                (e) => Participant.fromMap(e),
              )
              .toList(growable: false);
          return _list;
        },
      );

  Stream<Participant?> get allTimeRecord => allTimeRecordRef.onValue.map(
        (event) {
          if (event.snapshot.value == null) return null;

          final Map map = event.snapshot.value;
          print("tD-49 $map");

          final Participant participant = Participant.fromMap(map.values.first);
          return participant;
        },
      );

  /*Stream<Participant> get todayWinner =>
      super.tournamentRef.child("todayWinner").child(path).onValue.map(
        (event) {
          final map = event.snapshot.value;
          Participant participant = Participant.fromMap(map);
          return participant;
        },
      );*/

  Stream<String?> get todayWinner => todayWinnerRef.onValue.map(
        (event) {
          print("todayWinner ID ${event.snapshot.value}");
          if (event.snapshot.value == null) return null;
          return event.snapshot.value as String;
        },
      );

  Future get setTodayWinner async => todayWinnerRef.set(uid);

  Future<Participant?> get myScore => tournamentPlayerRef.once().then(
        (DataSnapshot snapshot) {
          if (snapshot.value == null) return null;
          final map = snapshot.value;
          final Participant participant = Participant.fromMap(map);
          return participant;
        },
      );

  Stream<bool> get participantsAvailable {
    late BehaviorSubject<bool> behaviorSubject;

    behaviorSubject = BehaviorSubject<bool>(
      onListen: () => participantsQuery.onValue.listen(
        (event) {
          final a = event.snapshot.value;
          if (a == null)
            behaviorSubject.add(false);
          else {
            behaviorSubject.add(true);
          }
        },
      ),
    );
    return behaviorSubject.stream;
  }

  Future<bool> updateDuration(Participant participant) async {
    final TransactionResult transactionResult =
        await tournamentPlayerRef.runTransaction(
      (mutableData) async {
        print("Updating duration runTransaction");
        if (mutableData.value == null)
          mutableData.value = participant.toMap(newGame: true);
        else {
          //final Map map = mutableData.value;
          //final Participant _participant = Participant.fromMap(map);
          // if (participant.duration < _participant.duration)
          mutableData.value = participant.toMap();
        }
        return mutableData;
      },
    );
    return transactionResult.committed;
  }

  Future updateAllTimeRecord(Participant participant) async =>
      await allTimeRecordRef.runTransaction(
        (mutableData) async {
          print("updateAllTime Record runTransaction");
          if (mutableData.value == null)
            mutableData.value = <String, dynamic>{
              uid!: participant.toMap(),
            };
          else {
            final Map map = mutableData.value;
            final Participant _p = Participant.fromMap(map.values.first);
            if (participant.duration < _p.duration)
              mutableData.value = <String, dynamic>{
                uid!: participant.toMap(),
              };
          }
          return mutableData;
        },
      );

  Future<Participant?> todayParticipant(String id) async => super
          .tournamentRef
          .child("participants/$id")
          // .equalTo(_today, key: 'date')
          .orderByChild('date')
          .equalTo(_today)
          .reference()
          .once()
          .then(
        (snapshot) {
          if (snapshot.value == null) return null;
          final Map map = snapshot.value;
          final Participant participant = Participant.fromMap(map);
          return participant;
        },
      );

  /*Future<bool> checkWinner(double value) async => participantsQuery.once().then(
        (snapshot) {
          print("checkWinner snapshot --my value $value");
          print(snapshot.value);
          final Map map = snapshot.value;
          //map.values.where((element) => false)
          return true;
        },
      );*/
}
