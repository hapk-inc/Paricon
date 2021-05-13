import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/services/auth.dart';

import 'newNameProvider.dart';

final firebaseAppProvider = FutureProvider<FirebaseApp>(
  (_) async => await Future.delayed(
    const Duration(milliseconds: 500),
    () => Firebase.initializeApp(),
  ),
  name: "firebaseAppProvider",
);

final authProvider = Provider<Auth>(
  (ref) {
    final app = ref.read(firebaseAppProvider).data.value;
    return Auth(app);
  },
);

final userCheckProvider = StreamProvider<bool>(
  (ref) {
    final auth = ref.read(authProvider);
    return auth.userCheck;
  },
  name: "userCheckProvider",
);

final anonymousProvider = FutureProvider.autoDispose(
  (ref) async {
    final auth = ref.read(authProvider);
    final name = ref.read(newNameNotifier.notifier);
    await auth.signInAnonymous(name: name.state);
  },
  name: 'anonymousProvider',
);

final googleSignInProvider = FutureProvider.autoDispose(
  (ref) async {
    final auth = ref.read(authProvider);
    await auth.signInWithGoogle();
  },
);

final firebaseUserProvider = Provider.autoDispose<User>(
  (ref) {
    final auth = ref.read(authProvider);
    return auth.currentUser;
  },
);

final currentUserProvider = Provider.autoDispose<User>(
  (ref) {
    final auth = ref.read(authProvider);
    return auth.currentUser;
  },
);

final signOutProvider = FutureProvider.autoDispose(
  (ref) async {
    final auth = ref.read(authProvider);
    auth.signOut;
  },
);
