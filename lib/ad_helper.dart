import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Production AdMob App ID: ca-app-pub-9046523366518719~9727487174
  
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid || Platform.isIOS) {
      // Production Banner Ad Unit ID
      return 'ca-app-pub-9046523366518719/8056322012';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid || Platform.isIOS) {
      // Production Interstitial Ad Unit ID
      return 'ca-app-pub-9046523366518719/6071398911';
    }
    return '';
  }
}
