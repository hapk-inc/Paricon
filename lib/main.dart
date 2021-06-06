import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:paricon/screens/common/circularProgressTheme.dart';
import 'package:paricon/screens/common/durationCount.dart';
import 'package:paricon/screens/providers/packageInfoProvider.dart';
import 'package:paricon/screens/providers/updateProvider.dart';

import 'screens/common/buttonStyleTheme.dart';
import 'screens/common/paddingTheme.dart';
import 'screens/common/textTheme.dart';
import 'screens/dashboard.dart';
import 'screens/providers/authProvider.dart';
import 'screens/providers/pageProvider.dart';
import 'screens/splash.dart';
import 'screens/welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyApp()));
}

/*final packageProvider = await ref.read(packageInfoProvider!.future);

if (!packageProvider.version.contains("dev")) {
if (playersProvider.length == 1)
return Future.error("Wait for Other Players");
}*/

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) => MaterialApp(
        home: AnimatedSwitcher(
          duration: DurationCount.m500,
          child: watch(packageInfoProvider!).maybeWhen(
            data: (value) => value.version.contains("dev")
                ? FirebaseInit()
                : watch(inAppUpdateProvider).when(
                    data: (value) => value.updateAvailability ==
                            UpdateAvailability.updateAvailable
                        ? AppUpdate()
                        : FirebaseInit(),
                    loading: () => Splash(),
                    error: (error, stackTrace) =>
                        CircularProgressTheme.pinkIndicator,
                  ),
            orElse: () => Splash(),
          ),
        ),
      );
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
      ),
    );
  }
}

class AppUpdate extends StatelessWidget {
  const AppUpdate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.red,
        body: Container(
          alignment: Alignment.center,
          padding: PaddingTheme.all8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: AutoSizeText(
                  "Kindly update the app to check the latest updates",
                  textAlign: TextAlign.center,
                  style: TextStyleFontTheme.poppins.copyWith(
                    fontSize: 32,
                    color: Colors.white70,
                  ),
                  minFontSize: 24,
                  maxFontSize: 48,
                ),
              ),
              Spacer(),
              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 0.25,
                  child: ElevatedButton(
                    style: ButtonStyleTheme.buildDashboardButtonStyle(
                        btnColor: Colors.red),
                    onPressed: () {
                      InAppUpdate.performImmediateUpdate().catchError(
                        (error, _) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reopen the app again for update.',
                                style: TextStyleFontTheme.poppins,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: AutoSizeText(
                      "Update",
                      style: TextStyleFontTheme.poppins.copyWith(fontSize: 32),
                      minFontSize: 24,
                      maxFontSize: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
