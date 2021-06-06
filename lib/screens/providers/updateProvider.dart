import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';

final inAppUpdateProvider = FutureProvider.autoDispose<AppUpdateInfo>(
    (_) async => InAppUpdate.checkForUpdate());
