import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = ChangeNotifierProvider<ConnectivityNotifier>(
  (_) => ConnectivityNotifier(),
);

class ConnectivityNotifier extends ChangeNotifier {
  ConnectivityNotifier() {
    Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _connectivityResult = result;
        notifyListeners();
      },
    );
  }
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  ConnectivityResult get connectivityResult => _connectivityResult;
}
