import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final adStateProvider = Provider<AdState>(
  (_) {
    final initFuture = MobileAds.instance.initialize();
    return AdState(initFuture);
  },
);

class AdState {
  final Future<InitializationStatus> initialization;

  AdState(this.initialization);

  String get bannerAdUnitId => kDebugMode
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-9914451988705540/8545570510";

  String get interstitialAdUnitId => kDebugMode
      ? "ca-app-pub-3940256099942544/1033173712"
      : "ca-app-pub-9914451988705540/9384656264";

  BannerAdListener get bannerAdListener => _bannerAdListener;

  InterstitialAdLoadCallback _interstitialAdLoadCallback =
      InterstitialAdLoadCallback(
    onAdLoaded: (ad) => print("Interstitial Ad Loaded"),
    onAdFailedToLoad: (error) => print("Interstitial Ad error"),
  );

  InterstitialAdLoadCallback get interstitialAdLoadCallback =>
      _interstitialAdLoadCallback;

  BannerAdListener _bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => print("Ad Loaded"),
    onAdClosed: (ad) => print("Ad Closed"),
    onAdOpened: (ad) => print("Ad opened"),
  );
}
