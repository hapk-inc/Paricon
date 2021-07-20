import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'packageInfoProvider.dart';
import '/services/auth.dart';

import 'databaseProvider.dart';
import 'newNameProvider.dart';

final firebaseAppProvider = FutureProvider<FirebaseApp>(
  (_) async => await Future.delayed(
    const Duration(milliseconds: 500),
    () async {
      final app = await Firebase.initializeApp();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      return app;
    },
  ),
  name: "firebaseAppProvider",
);

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>(
  (_) {
    final analytics = FirebaseAnalytics();
    analytics.setAnalyticsCollectionEnabled(true);
    return analytics;
  },
);

final debugAndAppNameProvider = FutureProvider<bool>(
  (ref) async {
    final package = await ref.read(packageInfoProvider!.future);

    return package.appName.contains("Dev") || kDebugMode;
  },
);

final authProvider = Provider<Auth>(
  (ref) {
    final app = ref.read(firebaseAppProvider).data!.value;
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

final AutoDisposeFutureProvider<Null>? anonymousProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final auth = ref.read(authProvider);
    final name = ref.read(newNameNotifier.notifier);
    await auth.signInAnonymous(name: name.state);
  },
  name: 'anonymousProvider',
);

final AutoDisposeFutureProvider<Null>? googleSignInProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final auth = ref.read(authProvider);
    await auth.signInWithGoogle;
  },
);

final AutoDisposeProvider<User>? firebaseUserProvider =
    Provider.autoDispose<User>(
  (ref) {
    final auth = ref.read(authProvider);
    return auth.currentUser!;
  },
);

final AutoDisposeFutureProvider<Null>? signOutProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final auth = ref.read(authProvider);
    await auth.signOut;
  },
);

final AutoDisposeFutureProvider updateMetaDataProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final firebaseUser = ref.read(firebaseUserProvider!);
    final playerDatabase = ref.read(playerDatabaseProvider!(firebaseUser.uid));
    await playerDatabase.updateMetaData;
  },
);
