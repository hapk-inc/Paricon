import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:paricon/models/tournament.dart';
import 'package:rxdart/rxdart.dart';
import 'database.dart';

class TournamentDatabase extends MyDatabase {
  final String? uid;
  TournamentDatabase(FirebaseApp app, {this.uid}) : super(app);

  /*Stream<Tournament> get tournament {to
    BehaviorSubject<Tournament> behaviorSubject;
    behaviorSubject = BehaviorSubject(
      onListen: () => super.tournamentRef.onValue.listen(
            (event) {},
          ),
    );
    return behaviorSubject.stream;
  }*/

  DatabaseReference get tournamentPlayerRef =>
      super.tournamentRef.child("participants/$uid");

  Query get participantsQuery =>
      super.tournamentRef.child("participants").orderByChild("duration");

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

  Stream<double> get allTimeRecord => super
      .tournamentRef
      .child("allTimeRecord")
      .onValue
      .map((event) => double.parse(event.snapshot.value as String));

  Stream<Participant> get todayWinner =>
      super.tournamentRef.child("todayWinner").onValue.map(
        (event) {
          final map = event.snapshot.value;
          Participant participant = Participant.fromMap(map);
          return participant;
        },
      );

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
            behaviorSubject.close();
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
        if (mutableData.value == null)
          mutableData.value = participant.toMap();
        else {
          final Map map = mutableData.value;
          final Participant _participant = Participant.fromMap(map);
          if (participant.duration < _participant.duration)
            mutableData.value = participant.toMap();
        }
        return mutableData;
      },
    );
    return transactionResult.committed;
  }
}
