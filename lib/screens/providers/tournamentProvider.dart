import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/models/localIcon.dart';
import '/models/tournament.dart';
import 'authProvider.dart';
import 'databaseProvider.dart';
import 'gameIconProvider.dart';

final AutoDisposeProvider<Query>? participantsQueryProvider =
    Provider.autoDispose<Query>(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return tournamentDatabase.participantsQuery;
  },
);

final AutoDisposeStreamProvider<bool> participantsAvailableProvider =
    StreamProvider.autoDispose<bool>(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return tournamentDatabase.participantsAvailable;
  },
);

/*final AutoDisposeStreamProvider<List<Participant>> participantsProvider =
    StreamProvider.autoDispose<List<Participant>>(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return tournamentDatabase.participants;
  },
);*/

//change to AutoDispose --not working
final allTimeRecordProvider = StreamProvider<Participant?>(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return tournamentDatabase.allTimeRecord;
  },
);

//change to autoDispose --not working
final StreamProvider<String?> todayWinnerProvider = StreamProvider<String?>(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);

    return tournamentDatabase.todayWinner;
  },
);

final AutoDisposeFutureProvider<Participant?> todayParticipantProvider =
    FutureProvider.autoDispose<Participant?>(
  (ref) async {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    final String? id = await ref.watch(todayWinnerProvider.last);
    print(id);
    if (id == null) return null;
    //if (id == null)
    //  return Participant(name: "Unknown", id: "3433343", duration: 232.43);
    print("From todayID provider $id");
    return tournamentDatabase.todayParticipant(id);
  },
);

/*final AutoDisposeFutureProviderFamily<bool, double> checkWinnerProvider =
    FutureProvider.autoDispose.family<bool, double>(
  (ref, value) async {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);

    final bool isWinner = await tournamentDatabase.checkWinner(value);
    print("isWinner check-73 $isWinner");
    if (isWinner) tournamentDatabase.setTodayWinner;
    return isWinner;
  },
);*/

/*final AutoDisposeFutureProviderFamily<void, Participant>
    updateAllTimeCheckProvider =
    FutureProvider.autoDispose.family<void, Participant>(
  (ref, p) async {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    tournamentDatabase.updateAllTimeRecord(p);
  },
);*/

/*final AutoDisposeStreamProvider<Participant?> todayWinnerProvider =
    StreamProvider.autoDispose<Participant>(
  (ref) =>
      Stream.value(Participant(name: "Unknown", id: "000", duration: 4123.34)),
);*/

final AutoDisposeFutureProvider<Participant?> myParticipantProvider =
    FutureProvider.autoDispose(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return tournamentDatabase.myScore;
  },
);
final AutoDisposeFutureProviderFamily<bool, Participant>
    updateParticipantProvider =
    FutureProvider.autoDispose.family<bool, Participant>(
  (ref, participant) async {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);

    bool _newWinner = false;
    bool _newRecord = false;

    final winnerID = await ref.read(todayWinnerProvider.last);
    if (winnerID == null)
      _newWinner = true;
    else {
      final firebaseUser = ref.read(firebaseUserProvider!);
      _newWinner = firebaseUser.uid != winnerID;
    }

    if (_newWinner) {
      final allTimeRecord = await ref.read(allTimeRecordProvider.last);
      if (allTimeRecord == null)
        _newRecord = true;
      else {
        if (participant.duration < allTimeRecord.duration) {
          _newRecord = true;
        }
      }
    }
    print("newWinner $_newWinner");
    print("newRecord $_newRecord");

    await Future.wait(
      [
        tournamentDatabase.updateDuration(participant),
        if (_newWinner) tournamentDatabase.setTodayWinner,
        if (_newRecord) tournamentDatabase.updateAllTimeRecord(participant)
      ],
    );

    return _newWinner;
  },
);

final tournamentNotifierProvider =
    ChangeNotifierProvider.autoDispose<TournamentNotifier>(
  (ref) {
    final xIcons = ref.read(gameIconProvider);

    return TournamentNotifier(xIcons.tournamentIcons);
  },
);

extension TimeConversion on TimeOfDay {
  double get doubleConversion => this.hour + (this.minute / 60);
  bool validTime({int start = 9, int end = 21}) =>
      TimeOfDay(hour: start, minute: 0).doubleConversion <
          this.doubleConversion &&
      this.doubleConversion < TimeOfDay(hour: end, minute: 0).doubleConversion;
}

extension DoubleTimeConversion on double {
  int get inMinutes => (this.toInt() / 60).truncate();
  int get inSeconds => (this.toInt() % 60).truncate();
  int get inMilliSeconds {
    final a = ((this % 1) * pow(10, 3)).floor();
    return a;
  }

  String get inHHMM => "${this.inMinutes} : ${this.inSeconds}";
}

/*final checkTournamentTimeProvider = Provider.autoDispose<bool>(
  (_) {
    final TimeOfDay start = TimeOfDay(hour: 9, minute: 0);
    final TimeOfDay end = TimeOfDay(hour: 21, minute: 0);
    final TimeOfDay now = TimeOfDay.now();

    return kDebugMode ||
        (start.doubleConversion < now.doubleConversion &&
            now.doubleConversion < end.doubleConversion);
  },
);*/

final tournamentPlayedProvider = FutureProvider.autoDispose<Duration?>(
  (ref) async {
    final firebaseUser = ref.read(firebaseUserProvider!);
    final playerDatabase = ref.read(playerDatabaseProvider!(firebaseUser.uid));
    final Duration? duration = await playerDatabase.checkTournamentPlayed;
    if (duration == null)
      await playerDatabase.updateTournamentPlayed;
    else {
      final int timeGap = ref.read(timeGapProvider);
      if (duration.inMinutes > timeGap)
        await playerDatabase.updateTournamentPlayed;
    }
    return duration;
  },
);

final timeGapProvider = Provider<int>((_) => 9);

final liveTimeProvider = StreamProvider.autoDispose<TimeOfDay>(
  (_) => updateGameTime,
);

Stream<TimeOfDay> get updateGameTime async* {
  yield TimeOfDay.now();
  yield* Stream.periodic(Duration(minutes: 1), (_) => TimeOfDay.now());
}

TimeOfDay fromString(String s) => TimeOfDay(
      hour: int.parse(s.split(":")[0]),
      minute: int.parse(s.split(":")[1]),
    );

class TournamentNotifier extends ChangeNotifier {
  late List<LocalIcon> _icons;
  bool _loading = false;

  bool _isGameOver = false;

  bool get isGameOver => _isGameOver;
  Stopwatch? _stopwatch;
  late Timer _timer;
  Duration _duration = Duration.zero;

  TournamentNotifier(this._icons) {
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        _duration = _stopwatch!.elapsed;
        // notifyListeners();
      },
    );
    _stopwatch!.start();
  }

  Duration get duration => _duration;

  bool get loading => _loading;

  List<LocalIcon> get icons => _icons;

  validateIcons(int index) async {
    _loading = true;

    icons[index] = icons[index].copyWith(isCheck: true);
    notifyListeners();

    final validateIcons = icons.where((element) => element.isCheck).toList();
    if (validateIcons.length == 2) {
      if (validateIcons.first.checkIconCode(validateIcons.last)) {
        await Future.delayed(
          Duration(milliseconds: 500),
          () {
            validateIcons.forEach(
              (element) {
                icons[element.iconNo! - 1] = element.copyWith(
                  isCheck: false,
                  isFound: true,
                  color: "blue",
                );
              },
            );

            //_isGameOver = true;
            //_isGameOver =
            //    icons.every((element) => element.isFound && !element.isCheck);
            final check10 = icons
                .where((element) => element.isFound && !element.isCheck)
                .toList();
            _isGameOver = check10.length == 10;
            if (_isGameOver) stopTime();
          },
        );
      } else {
        await Future.delayed(
          Duration(milliseconds: 500),
          () {
            validateIcons.forEach(
              (element) {
                icons[element.iconNo! - 1] = element.copyWith(isCheck: false);
              },
            );
          },
        );
      }
    }
    _loading = false;
    notifyListeners();
  }

  stopTime() {
    _timer.cancel();
    _stopwatch!.stop();
    _duration = _stopwatch!.elapsed;
    notifyListeners();
  }

  double get timeDoubleConversion {
    print(duration.inMinutes);
    print(duration.inSeconds);
    print(duration.inMilliseconds);
    return double.parse("${(duration.inMinutes * 60) + duration.inSeconds}."
        "${duration.inMilliseconds}");
  }

  Participant updateParticipant(Participant participant) {
    late Participant p;
    if (participant.duration > timeDoubleConversion) {
      p = participant.copyWith(
          duration: timeDoubleConversion,
          gamesPlayed: participant.gamesPlayed + 1);
    } else
      p = participant.copyWith(gamesPlayed: participant.gamesPlayed + 1);
    return p;
  }
}
