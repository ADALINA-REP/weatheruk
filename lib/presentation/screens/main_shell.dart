import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/uhd_bottom_nav.dart';
import '../widgets/ad_banner.dart';
import '../providers/location_provider.dart';
import '../../core/ads_service.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    
    int currentIndex = 0;
    if (location == '/') currentIndex = 0;
    else if (location == '/favorites') currentIndex = 1;
    else if (location == '/radar') currentIndex = 2;
    else if (location == '/details') currentIndex = 3;
    else if (location == '/settings') currentIndex = 4;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBanner(),
          UhdBottomNav(
            currentIndex: currentIndex,
            onTap: (index) {
              if (index == currentIndex) return;
              
              AdsService.showInterstitialAd(
                onAdDismissed: () {
                  HapticFeedback.lightImpact();
                  switch (index) {
                    case 0:
                      context.go('/');
                      break;
                    case 1:
                      context.go('/favorites');
                      break;
                    case 2:
                      context.go('/radar');
                      break;
                    case 3:
                      final selectedLocation = ref.read(selectedLocationProvider);
                      final lat = selectedLocation.latitude;
                      final lon = selectedLocation.longitude;
                      final cityName = selectedLocation.name;
                      
                      context.go('/details', extra: {
                        'lat': lat,
                        'lon': lon,
                        'cityName': cityName,
                      });
                      break;
                    case 4:
                      context.go('/settings');
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
