import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Replace these test IDs with your production AdMob IDs when ready!
  
  // App IDs (Configured in Info.plist for iOS and AndroidManifest.xml for Android)
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // Android Banner Ad ID (Test ID: ca-app-pub-3940256099942544/6300978111)
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOS Banner Ad ID (Test ID: ca-app-pub-3940256099942544/2934735716)
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // Android Interstitial Ad ID (Test ID: ca-app-pub-3940256099942544/1033173712)
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // iOS Interstitial Ad ID (Test ID: ca-app-pub-3940256099942544/4411468910)
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }
}
