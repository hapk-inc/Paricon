import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'screens/appUpdate.dart';
import 'screens/common/circularProgressTheme.dart';
import 'screens/common/durationCount.dart';

import 'screens/providers/updateProvider.dart';

import 'screens/dashboard.dart';
import 'screens/providers/authProvider.dart';
import 'screens/providers/pageProvider.dart';
import 'screens/splash.dart';
import 'screens/welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimatedSwitcher(
        duration: DurationCount.m500,
        child: Consumer(
          builder: (context, watch, child) =>
              watch(debugAndAppNameProvider).maybeWhen(
            orElse: () => CircularProgressTheme.pinkIndicator,
            data: (check) => check
                ? FirebaseInit()
                : watch(inAppUpdateProvider).when(
                    data: (value) => value.updateAvailability ==
                            UpdateAvailability.updateAvailable
                        ? AppUpdate()
                        : FirebaseInit(),
                    loading: () => Splash(),
                    error: (err, stk) => CircularProgressTheme.pinkIndicator,
                  ),
          ),
        ),
      ),
    );
  }
}

class FirebaseInit extends ConsumerWidget {
  FirebaseInit({Key? key}) : super(key: key);
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _pages = watch(pageProvider);

    final _firebaseApp = watch(firebaseAppProvider);
    return WillPopScope(
      onWillPop: () async => !await _navigatorKey.currentState!.maybePop(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _firebaseApp.maybeWhen(
          data: (_) => ProviderListener(
            provider: userCheckProvider,
            onChange: (BuildContext context, AsyncValue<bool> asyncValue) {
              final pageCtx = context.read(pageProvider);
              final analytics = context.read(firebaseAnalyticsProvider);

              asyncValue.whenData(
                (userAvailable) async {
                  analytics.logAppOpen();
                  if (userAvailable) {
                    context.read(updateMetaDataProvider);
                    pageCtx.replaceAll(Dashboard.toMaterialPage);
                  } else {
                    pageCtx.replaceAll(Welcome.toMaterialPage);
                  }
                },
              );
            },
            child: AnimatedSwitcher(
              child: _pages.pages.isEmpty
                  ? Scaffold(backgroundColor: Colors.red)
                  : Navigator(
                      pages: _pages.pages,
                      onPopPage: _pages.handlePopPage,
                      key: _navigatorKey,
                      observers: [
                        FirebaseAnalyticsObserver(
                          analytics: context.read(firebaseAnalyticsProvider),
                        ),
                      ],
                    ),
              duration: DurationCount.m500,
            ),
          ),
          orElse: () => Splash(),
        ),
      ),
    );
  }
}
