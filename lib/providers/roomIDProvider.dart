import 'package:flutter_riverpod/flutter_riverpod.dart';

final idNotifier = StateNotifierProvider<IDNotifier, String>(
  (ref) {
    return IDNotifier();
  },
);

class IDNotifier extends StateNotifier<String> {
  IDNotifier() : super("");

  @override
  set state(String value) {
    super.state = value;
  }

  empty() {
    state = "";
  }
}
