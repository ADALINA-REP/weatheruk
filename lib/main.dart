import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/ads_service.dart';
import 'core/theme.dart';
import 'data/models/weather_models.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/radar_screen.dart';
import 'presentation/screens/weather_details_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/daily_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force preferred orientation to portrait for iOS & Android
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style to transparent dark mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize AdMob asynchronously
  if (!kIsWeb) {
    await AdsService.initialize();
  }

  runApp(
    const ProviderScope(
      child: WeatherUKApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/radar',
          builder: (context, state) => const RadarScreen(),
        ),
        GoRoute(
          path: '/details',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final lat = extra?['lat'] as double? ?? 51.5074;
            final lon = extra?['lon'] as double? ?? -0.1278;
            final cityName = extra?['cityName'] as String? ?? 'London';
            return WeatherDetailsScreen(lat: lat, lon: lon, cityName: cityName);
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/daily-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final weather = extra!['weather'] as WeatherResponse;
        final dayIndex = extra['dayIndex'] as int? ?? 0;
        final cityName = extra['cityName'] as String? ?? 'London';
        return DailyDetailsScreen(
          weather: weather,
          dayIndex: dayIndex,
          cityName: cityName,
        );
      },
    ),
  ],
);

class WeatherUKApp extends StatelessWidget {
  const WeatherUKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WeatherUK Radar',
      debugShowCheckedModeBanner: false,
      theme: WeatherTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
