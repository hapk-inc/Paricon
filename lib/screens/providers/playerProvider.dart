import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/profile.dart';

import 'authProvider.dart';
import 'databaseProvider.dart';

final AutoDisposeFutureProvider<Profile?> profileProvider =
    FutureProvider.autoDispose<Profile?>(
  (ref) async {
    final auth = ref.read(firebaseUserProvider!);
    final playerDatabase = ref.read(playerDatabaseProvider(auth.uid));
    return playerDatabase.profile;
  },
);

final AutoDisposeFutureProviderFamily<Profile?, String>? otherProfileProvider =
    FutureProvider.autoDispose.family<Profile?, String>(
  (ref, uid) async {
    final playerDatabase = ref.read(playerDatabaseProvider(uid));
    ref.maintainState = false;
    return playerDatabase.profile;
  },
);

final createProfileProvider = FutureProvider.autoDispose(
  (ref) async {
    final auth = ref.read(firebaseUserProvider!);
    final playerDatabase = ref.read(playerDatabaseProvider(auth.uid));
    await playerDatabase.createProfile(auth);
  },
);

final allUsersProvider =
    StreamProvider.autoDispose.family<List<Profile>, String>(
  (ref, level) {
    final playerDatabase = ref.read(playerDatabaseProvider(""));
    return playerDatabase.allUsers(level);
  },
);
final AutoDisposeFutureProviderFamily<void, String>? updateNameProvider =
    FutureProvider.autoDispose.family<void, String>(
  (ref, playerName) async {
    final auth = ref.read(authProvider);
    await auth.updateName(playerName);
  },
);
