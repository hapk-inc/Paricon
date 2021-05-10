import 'package:flutter_riverpod/flutter_riverpod.dart';

final newNameNotifier = StateNotifierProvider<NameNotifier, String>(
  (_) => NameNotifier(),
);

class NameNotifier extends StateNotifier<String> {
  NameNotifier() : super("");

  @override
  set state(String value) {
    super.state = value;
  }
}
