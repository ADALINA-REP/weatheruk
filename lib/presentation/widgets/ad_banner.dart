import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/ads_service.dart';

enum AdType { banner, largeSquare }

class AdBanner extends StatefulWidget {
  final AdType type;
  const AdBanner({super.key, this.type = AdType.banner});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _loadAd();
    }
  }

  @override
  void didUpdateWidget(AdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _bannerAd?.dispose();
      _isLoaded = false;
      _loadFailed = false;
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _loadAd();
      }
    }
  }

  void _loadAd() {
    final adSize = widget.type == AdType.largeSquare ? AdSize.mediumRectangle : AdSize.banner;
    
    _bannerAd = BannerAd(
      adUnitId: AdsService.bannerAdUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _loadFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('Ad failed to load: $err');
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _loadFailed = true;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = widget.type == AdType.largeSquare;
    final width = isLarge ? 300.0 : 320.0;
    final height = isLarge ? 250.0 : 50.0;

    if (kIsWeb) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: isLarge ? 300 : double.infinity,
        constraints: BoxConstraints(maxWidth: isLarge ? 300 : 728, maxHeight: height),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: const Text(
                'AD',
                style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isLarge ? 'WeatherUK Sponsored' : 'Sponsored • WeatherUK Radar',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (_isLoaded && _bannerAd != null) {
        final double adWidth = _bannerAd!.size.width.toDouble();
        final double adHeight = _bannerAd!.size.height.toDouble();

        return Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          width: adWidth,
          height: adHeight,
          child: AdWidget(
            key: ValueKey(_bannerAd.hashCode),
            ad: _bannerAd!,
          ),
        );
      }

      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars_rounded, color: Colors.amber.withOpacity(0.7), size: 16),
            const SizedBox(width: 6),
            Text(
              _loadFailed ? 'Sponsored Ad' : 'Loading Ad...',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
