import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info/package_info.dart';

final packageInfoProvider = FutureProvider.autoDispose<PackageInfo>(
  (_) => PackageInfo.fromPlatform(),
);
