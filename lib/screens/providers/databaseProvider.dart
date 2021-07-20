import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/services/boardDatabase.dart';
import '/services/playerDatabase.dart';
import '/services/roomDatabase.dart';
import '/services/tournamentDatabase.dart';

import 'authProvider.dart';
import 'roomIDProvider.dart';

final ProviderFamily<PlayerDatabase, String>? playerDatabaseProvider =
    Provider.family<PlayerDatabase, String>(
  (ref, id) {
    final app = ref.read(firebaseAppProvider).data!.value;
    return PlayerDatabase(app, uid: id);
  },
);

final AutoDisposeProvider<RoomDatabase>? roomDatabaseProvider =
    Provider.autoDispose<RoomDatabase>(
  (ref) {
    final app = ref.read(firebaseAppProvider).data!.value;
    final id = ref.watch(idNotifier.notifier).state;
    //final id = ref.watch(onlineBoardNotifier).roomID;

    return RoomDatabase(app, id: id);
  },
);

final AutoDisposeProvider<BoardDatabase>? boardDatabaseProvider =
    Provider.autoDispose<BoardDatabase>(
  (ref) {
    final id = ref.read(idNotifier.notifier).state;
    //final id = ref.read(onlineBoardNotifier).roomID;
    final app = ref.read(firebaseAppProvider).data!.value;
    return BoardDatabase(app, id: id);
  },
);

final AutoDisposeProvider<TournamentDatabase>? tournamentDatabaseProvider =
    Provider.autoDispose<TournamentDatabase>(
  (ref) {
    final app = ref.read(firebaseAppProvider).data!.value;
    final firebaseUser = ref.read(firebaseUserProvider!);
    return TournamentDatabase(app, uid: firebaseUser.uid);
  },
);
