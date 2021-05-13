import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/authProvider.dart';
import 'providers/pageProvider.dart';
import 'screens/dashboard.dart';
import 'screens/splash.dart';
import 'screens/welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          textTheme: TextTheme(
            bodyText1: const TextStyle(
                fontFamily: 'Poppins', color: Colors.white70, fontSize: 24),
            bodyText2: const TextStyle(
                fontFamily: 'LuckiestGuy', color: Colors.black87, fontSize: 24),
            button: const TextStyle(
              fontFamily: 'Bangers',
              color: Colors.black87,
              fontSize: 24,
              letterSpacing: 5,
            ),
            overline: const TextStyle(
              fontFamily: 'OriginalSurfer',
              color: Colors.black87,
              fontSize: 24,
            ),
            caption: const TextStyle(
                fontFamily: 'MeriendaOne', color: Colors.black87, fontSize: 24),
          ),
        ),
        home: WillPopScope(
          child: Consumer(
            builder: (BuildContext ctxt,
                T Function<T>(ProviderBase<Object, T>) watch, Widget child) {
              final _pages = watch(pageProvider);
              final _firebaseApp = watch(firebaseAppProvider);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _firebaseApp.maybeWhen(
                  data: (value) => ProviderListener<AsyncValue<bool>>(
                    onChange: (context, user) => user.whenData(
                      (_userCheck) {
                        print("User Check is $_userCheck");
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
                          ? Scaffold(
                              backgroundColor: Colors.red,
                              body: CircularProgressIndicator(),
                            )
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
            },
          ),
          onWillPop: () async => !await _navigatorKey.currentState.maybePop(),
        ),
      );
}
