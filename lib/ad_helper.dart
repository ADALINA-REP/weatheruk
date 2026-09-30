import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Android Play Store App ID: ca-app-pub-3159418819762571~3766115453
  // iOS App Store App ID:     ca-app-pub-9046523366518719~9727487174
  
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // Play Store Android Banner ID
      return 'ca-app-pub-3159418819762571/2006688529';
    } else if (Platform.isIOS) {
      // App Store iOS Banner ID
      return 'ca-app-pub-9046523366518719/8056322012';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // Play Store Android Interstitial ID
      return 'ca-app-pub-3159418819762571/4353650266';
    } else if (Platform.isIOS) {
      // App Store iOS Interstitial ID
      return 'ca-app-pub-9046523366518719/6071398911';
    }
    return '';
  }
}
