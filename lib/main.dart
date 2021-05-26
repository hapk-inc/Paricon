import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: WillPopScope(
          child: Consumer(
            builder: (context, watch, child) {
              final _pages = watch(pageProvider);
              final _firebaseApp = watch(firebaseAppProvider);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _firebaseApp.maybeWhen(
                  data: (value) => ProviderListener<AsyncValue<bool>>(
                    onChange: (context, user) => user.whenData(
                      (_userCheck) {
                        if (_userCheck)
                          _pages.replaceAll(Dashboard.toMaterialPage);
                        else
                          _pages.replaceAll(Welcome.toMaterialPage);
                      },
                    ),
                    provider: userCheckProvider,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _pages.pages.isEmpty
                          ? Scaffold(backgroundColor: Colors.red)
                          : Navigator(
                              pages: _pages.pages,
                              onPopPage: _pages.handlePopPage,
                              key: _navigatorKey,
                            ),
                    ),
                  ),
                  orElse: () => Splash(),
                ),
              );
            } /*as Widget Function(BuildContext, T Function<T>(ProviderBase<Object?, T>), Widget?)*/,
          ),
          onWillPop: () async => !await _navigatorKey.currentState!.maybePop(),
        ),
      );
}
