import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/models/localIcon.dart';
import '/models/tournament.dart';
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
    StreamProvider.autoDispose<bool>((ref) {
  final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
  return tournamentDatabase.participantsAvailable;
});

final AutoDisposeStreamProvider<List<Participant>> participantsProvider =
    StreamProvider.autoDispose<List<Participant>>(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return tournamentDatabase.participants;
  },
);

final AutoDisposeStreamProvider<double> allTimeRecordProvider =
    StreamProvider.autoDispose<double>(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return tournamentDatabase.allTimeRecord;
  },
);

final AutoDisposeStreamProvider<Participant?> todayWinnerProvider =
    StreamProvider.autoDispose<Participant>(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return Stream.value(
        Participant(name: "Unknown", id: "000", duration: 4123.34));
  },
);

final FutureProvider<Participant?> myParticipantProvider = FutureProvider(
  (ref) {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    return tournamentDatabase.myScore;
  },
);
final AutoDisposeFutureProviderFamily<void, Participant>
    updateParticipantProvider =
    FutureProvider.autoDispose.family<void, Participant>(
  (ref, participant) async {
    final tournamentDatabase = ref.read(tournamentDatabaseProvider!);
    tournamentDatabase.updateDuration(participant);
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
}

extension DoubleTimeConversion on double {
  int get inMinutes => (this.toInt() / 60).truncate();
  int get inSeconds => (this.toInt() % 60).truncate();
  int get inMilliSeconds {
    final a = ((this % 1) * pow(10, 3)).floor();
    return a;
  }

  String get inHHMM => "${this.inMinutes} : ${this.inSeconds}";

  String get inHoursMinutes => "${this.inMinutes} : ${this.inSeconds} ";
}

final checkTournamentTimeProvider = Provider.autoDispose<bool>(
  (_) {
    final TimeOfDay start = TimeOfDay(hour: 9, minute: 0);
    final TimeOfDay end = TimeOfDay(hour: 21, minute: 0);
    final TimeOfDay now = TimeOfDay.now();
    return kDebugMode ||
        (start.doubleConversion < now.doubleConversion &&
            now.doubleConversion < end.doubleConversion);
  },
);

final liveTimeProvider =
    StreamProvider.autoDispose<TimeOfDay>((_) => liveTime2);

/*Stream<TimeOfDay> get liveTime1 {
  late BehaviorSubject<TimeOfDay> subject;

  subject = BehaviorSubject<TimeOfDay>(
    onListen: () => Stream.periodic(
      Duration(seconds: 1),
      (_) {
        final time = TimeOfDay.now();
        subject.add(time);
        //  if (time.minute == 21) subject.close();
      },
    ).listen((e) {
      print(e);
      print("Streeeemmm");
    }),
  );
  return subject.stream;
}*/

Stream<TimeOfDay> get liveTime2 async* {
  yield TimeOfDay.now();
  yield* Stream.periodic(Duration(minutes: 1), (_) => TimeOfDay.now());
}

/*Stream<TimeOfDay> get liveTimeStream async* {
  Stream.periodic(
    Duration(seconds: 1),
    (_) => TimeOfDay.now(),
  );
}*/

TimeOfDay fromString(String s) => TimeOfDay(
      hour: int.parse(s.split(":")[0]),
      minute: int.parse(s.split(":")[1]),
    );

/*Stream<TimeOfDay> getTime() async* {
  TimeOfDay currentTime = TimeOfDay.now();
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    yield currentTime;
  }
}*/

/*final leaderBoardNotifierProvider =
    ChangeNotifierProvider((_) => LeaderBoardNotifier());*/

/*class LeaderBoardNotifier extends ChangeNotifier {
  late bool _startTime, _endTime;

  /*LeaderBoardNotifier({int start = 9, int end = 21}) {
    TimeOfDay startTime = TimeOfDay(hour: 9, minute: 00);
    TimeOfDay endTime = TimeOfDay(hour: 0, minute: 26);

    _startTime = TimeOfDay.now().doubleConversion > startTime.doubleConversion;

    _endTime = TimeOfDay.now().doubleConversion < endTime.doubleConversion;
    notifyListeners();
  }*/

  bool get endTime => _endTime;

  bool get startTime => _startTime;
}*/

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
    print(icons[index].iconCode);
    print(DateTime.now());
    print(Timeline.now);
    print(TimeOfDay.now());

    print(DateTime.now().day);
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
            _isGameOver =
                icons.every((element) => element.isFound && !element.isCheck);
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
}
