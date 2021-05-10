import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/services/boardDatabase.dart';
import 'package:paricon/services/playerDatabase.dart';
import 'package:paricon/services/roomDatabase.dart';

import 'authProvider.dart';
import 'roomIDProvider.dart';

final playerDatabaseProvider = Provider.family<PlayerDatabase, String>(
  (ref, id) {
    final app = ref.read(firebaseAppProvider).data.value;
    return PlayerDatabase(app, uid: id);
  },
);

final roomDatabaseProvider = Provider.autoDispose<RoomDatabase>(
  (ref) {
    final app = ref.read(firebaseAppProvider).data.value;
    final id = ref.watch(idNotifier.notifier);

    return RoomDatabase(app, id: id.state);
  },
);

final boardDatabaseProvider = Provider.autoDispose<BoardDatabase>(
  (ref) {
    final id = ref.read(idNotifier.notifier);
    final app = ref.read(firebaseAppProvider).data.value;
    return BoardDatabase(app, id: id.state);
  },
);
