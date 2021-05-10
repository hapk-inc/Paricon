import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/authProvider.dart';
import 'providers/pageProvider.dart';
import 'screens/dashboard.dart';
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
              fontFamily: 'Poppins',
              color: Colors.white70,
              fontSize: 24,
            ),
            bodyText2: const TextStyle(
              fontFamily: 'LuckiestGuy',
              color: Colors.black87,
              fontSize: 24,
            ),
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
              fontFamily: 'MeriendaOne',
              color: Colors.black87,
              fontSize: 24,
            ),
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
                              /*print(FocusScope.of(context).hasFocus);
                              if (FocusScope.of(context).hasFocus)
                              FocusScope.of(context).unfocus();*/
                              if (_userCheck)
                                _pages.replaceAll(Dashboard.toMaterialPage);
                              else
                                _pages.replaceAll(Welcome.toMaterialPage);
                            },
                          ),
                      provider: userCheckProvider,
                      child: Navigator(
                        pages: _pages.pages.isNotEmpty
                            ? _pages.pages
                            : [Splash.toMaterialPage],
                        onPopPage: _pages.handlePopPage,
                        key: _navigatorKey,
                      )),
                  orElse: () => Scaffold(
                    backgroundColor: Colors.pink,
                  ),
                ),
              );
            },
          ),
          onWillPop: () async => !await _navigatorKey.currentState.maybePop(),
        ),
      );
}

class Splash extends StatelessWidget {
  const Splash({Key key}) : super(key: key);

  static MaterialPage get toMaterialPage => MaterialPage(
        child: Splash(),
        name: '/Splash',
        key: ValueKey('Splash'),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.brown,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hola",
              style:
                  Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 32),
            ),
            Text(
              "Hola",
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 32),
            ),
            Text(
              "Hola",
              style: Theme.of(context).textTheme.button.copyWith(
                    fontSize: 32,
                  ),
            ),
            Text(
              "Hola",
              style:
                  Theme.of(context).textTheme.overline.copyWith(fontSize: 32),
            ),
            Text(
              "Holaq",
              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 32),
            ),
          ],
        ),
      );
}
