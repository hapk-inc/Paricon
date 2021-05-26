import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/models/profile.dart';

import 'authProvider.dart';
import 'databaseProvider.dart';

final AutoDisposeFutureProvider<Profile>? profileProvider = FutureProvider.autoDispose<Profile>(
  (ref) async {
    final auth = ref.read(currentUserProvider!);
    final playerDatabase = ref.read(playerDatabaseProvider!(auth.uid));
    return playerDatabase.profile;
  },
);

final AutoDisposeFutureProviderFamily<Profile, String>? otherProfileProvider = FutureProvider.autoDispose.family<Profile, String>(
  (ref, uid) async {
    final playerDatabase = ref.read(playerDatabaseProvider!(uid));
    return playerDatabase.profile;
  },
);
