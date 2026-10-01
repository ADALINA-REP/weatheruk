import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../ad_helper.dart';

class AdsService {
  static bool _initialized = false;

  static String get bannerAdUnitId => AdHelper.bannerAdUnitId;
  static String get interstitialAdUnitId => AdHelper.interstitialAdUnitId;

  static Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }
    if (!Platform.isAndroid && !Platform.isIOS) return;

    await MobileAds.instance.initialize();
    _initialized = true;
  }

  static InterstitialAd? _interstitialAd;
  static int _interstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;
  
  static int _navigationCounter = 0;
  static DateTime? _lastAdShowTime;
  static const int adFrequencyThreshold = 3;
  static const Duration adTimeThreshold = Duration(minutes: 2);

  static void loadInterstitialAd() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          if (_interstitialLoadAttempts <= maxFailedLoadAttempts) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  static void showInterstitialAd({VoidCallback? onAdDismissed, bool force = false}) {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      if (onAdDismissed != null) onAdDismissed();
      return;
    }

    if (!force) {
      _navigationCounter++;
      final now = DateTime.now();
      final timeSinceLastAd = _lastAdShowTime == null 
          ? adTimeThreshold 
          : now.difference(_lastAdShowTime!);

      if (_navigationCounter < adFrequencyThreshold || timeSinceLastAd < adTimeThreshold) {
        if (onAdDismissed != null) onAdDismissed();
        return;
      }
    }

    if (_interstitialAd == null) {
      if (onAdDismissed != null) onAdDismissed();
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _lastAdShowTime = DateTime.now();
        _navigationCounter = 0;
        loadInterstitialAd();
        if (onAdDismissed != null) onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        loadInterstitialAd();
        if (onAdDismissed != null) onAdDismissed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
