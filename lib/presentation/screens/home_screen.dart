import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/weather_utils.dart';
import '../../core/localization_service.dart';
import '../../core/ads_service.dart';
import '../../data/models/weather_models.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/ad_banner.dart';
import '../widgets/dynamic_weather_icon.dart';
import '../widgets/weather_background.dart';
import '../widgets/solar_arc_widget.dart';
import '../widgets/outdoor_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Default to London, UK
  final defaultLat = 51.5074;
  final defaultLon = -0.1278;

  @override
  Widget build(BuildContext context) {
    final selectedLocation = ref.watch(selectedLocationProvider);
    final lat = selectedLocation.latitude;
    final lon = selectedLocation.longitude;
    final cityName = selectedLocation.name;

    final weatherAsync = ref.watch(weatherProvider((lat: lat, lon: lon)));
    final aqiAsync = ref.watch(airQualityProvider((lat: lat, lon: lon)));

    final lang = ref.watch(settingsProvider).languageCode;

    return Scaffold(
      body: weatherAsync.when(
        data: (weather) => WeatherBackground(
          weatherCode: weather.current!.weatherCode,
          isDay: weather.current!.isDay,
          precipitation: weather.current!.precipitation ?? 0.0,
          rainProb: weather.hourly.precipitationProbability.isNotEmpty
              ? (weather.hourly.precipitationProbability[0] ?? 0)
              : 0,
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(weatherProvider((lat: lat, lon: lon)));
                ref.invalidate(airQualityProvider((lat: lat, lon: lon)));
                return ref.read(weatherProvider((lat: lat, lon: lon)).future);
              },
              backgroundColor: const Color(0xFF1E293B),
              color: const Color(0xFF0170E3),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(cityName),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCurrentWeather(weather, lat, lon, cityName, lang),
                          const SizedBox(height: 24),
                          _buildSectionTitle(LocalizationService.translate('forecast_hourly', lang)),
                          const SizedBox(height: 12),
                          _buildHourlyForecast(weather, lang),
                          const SizedBox(height: 24),
                          aqiAsync.when(
                            data: (aqi) => Column(
                              children: [
                                _buildAqiCard(aqi.current.aqi ?? 0, lang),
                                const SizedBox(height: 16),
                                const AdBanner(type: AdType.largeSquare),
                              ],
                            ),
                            loading: () => const GlassCard(child: SizedBox(height: 100)),
                            error: (err, stack) => const SizedBox(),
                          ),
                          const SizedBox(height: 16),
                          _buildSectionTitle(LocalizationService.translate('forecast_7day', lang)),
                          const SizedBox(height: 12),
                          _buildDailyForecast(weather, cityName, lang),
                          const SizedBox(height: 24),
                          _buildOutdoorSection(weather, lang),
                          const SizedBox(height: 24),
                          _buildSectionTitle(LocalizationService.translate('solar_cycle', lang)),
                          const SizedBox(height: 12),
                          _buildSolarCycle(weather),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 160),
                  ),
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  'Failed to load weather: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(weatherProvider((lat: lat, lon: lon)));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(String cityName) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 56,
      floating: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
          onPressed: () => _showCitySearch(context),
        ),
      ],
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Weather',
              style: TextStyle(
                color: Color(0xFF0170E3),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: 'UK',
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherResponse weather, double lat, double lon, String cityName, String lang) {
    final current = weather.current!;
    final info = WeatherUtils.getWeatherInfo(current.weatherCode, current.isDay, lang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DynamicWeatherIcon(
              code: current.weatherCode,
              isDay: current.isDay,
              size: 64,
              precipitation: current.precipitation,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                cityName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          WeatherUtils.formatTemperature(
            current.temperature,
            isCelsius: ref.watch(settingsProvider).unit == TemperatureUnit.celsius,
          ),
          style: const TextStyle(
            fontSize: 76,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            color: Colors.white,
            height: 0.95,
            shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          info.description.toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem(Icons.water_drop_outlined, '${current.humidity}%'),
            const SizedBox(width: 24),
            _buildStatItem(Icons.air_rounded, '${current.windSpeed.toInt()} km/h'),
            const SizedBox(width: 24),
            _buildStatItem(Icons.compress_rounded, '${current.surfacePressure?.toInt() ?? 1013} hPa'),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            AdsService.showInterstitialAd(
              onAdDismissed: () => context.push('/details', extra: {'lat': lat, 'lon': lon, 'cityName': cityName}),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  LocalizationService.translate('more_details', lang),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildHourlyForecast(WeatherResponse weather, String lang) {
    final startIndex = WeatherUtils.getCurrentHourIndex(weather.hourly.time);

    return SizedBox(
      height: 135,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        itemBuilder: (context, index) {
          final actualIndex = startIndex + index;
          if (actualIndex >= weather.hourly.time.length) return const SizedBox();

          final timeStr = weather.hourly.time[actualIndex].split('T')[1].substring(0, 5);
          final temp = weather.hourly.temperatures[actualIndex] ?? 0;
          final code = weather.hourly.weatherCodes[actualIndex] ?? 0;
          final isDay = weather.hourly.isDay?[actualIndex] ?? 1;
          final emoji = WeatherUtils.getWeatherInfo(code, isDay, lang).iconEmoji;
          final rainProb = weather.hourly.precipitationProbability[actualIndex] ?? 0;

          return Container(
            width: 75,
            margin: const EdgeInsets.only(right: 12),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                children: [
                  Text(timeStr, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Text(
                    WeatherUtils.formatTemperature(
                      temp,
                      isCelsius: ref.watch(settingsProvider).unit == TemperatureUnit.celsius,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop, size: 10, color: Colors.cyanAccent),
                      const SizedBox(width: 2),
                      Text(
                        '$rainProb%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAqiCard(int aqi, String lang) {
    final color = WeatherUtils.getAqiColor(aqi);
    final desc = WeatherUtils.getAqiDescription(aqi, lang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            LocalizationService.translate('aqi_title', lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: (aqi / 500).clamp(0.0, 1.0),
                      strokeWidth: 6,
                      backgroundColor: Colors.white10,
                      color: color,
                    ),
                  ),
                  Text(
                    aqi.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc,
                      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocalizationService.translate('aqi_advice_good', lang),
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutdoorSection(WeatherResponse weather, String lang) {
    final current = weather.current!;
    final hourly = weather.hourly;

    final activities = [
      {'name': LocalizationService.translate('sport_running', lang), 'icon': '🏃', 'type': 'run'},
      {'name': LocalizationService.translate('sport_cycling', lang), 'icon': '🚴', 'type': 'bike'},
      {'name': LocalizationService.translate('sport_hiking', lang), 'icon': '🥾', 'type': 'hike'},
      {'name': 'Tennis', 'icon': '🎾', 'type': 'tennis'},
      {'name': 'Football', 'icon': '⚽', 'type': 'soccer'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            LocalizationService.translate('sport_outdoor', lang),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: activities.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final act = activities[index];

              String suggestion = LocalizationService.translate('smart_great_day', lang);
              String suggestionIcon = '✨';
              if (current.temperature < 10) {
                suggestion = LocalizationService.translate('smart_dress_warm', lang);
                suggestionIcon = '❄️';
              } else if (current.temperature > 30) {
                suggestion = LocalizationService.translate('smart_hydration', lang);
                suggestionIcon = '💧';
              } else if ((current.precipitation ?? 0) > 0) {
                suggestion = LocalizationService.translate('smart_stay_indoors', lang);
                suggestionIcon = '🏠';
              }

              final scoreData = WeatherUtils.calculateOutdoorScore(
                current.temperature,
                current.windSpeed,
                hourly.precipitationProbability.isNotEmpty ? (hourly.precipitationProbability[0] ?? 0) : 0,
                lang,
              );
              final status = scoreData['message'] as String;
              final statusDetail = (current.precipitation ?? 0) > 0
                  ? LocalizationService.translate('advice_storm', lang)
                  : LocalizationService.translate('advice_good_template', lang);

              final startIndex = WeatherUtils.getCurrentHourIndex(hourly.time);
              final timeline = List.generate(24, (i) {
                final hourIndex = startIndex + i + 1;
                if (hourIndex >= hourly.time.length) {
                  return TimelineItem(time: '--', emoji: '❓', status: 'N/A');
                }
                final fullTime = hourly.time[hourIndex].split('T')[1].substring(0, 5);
                final hourInt = int.parse(fullTime.substring(0, 2));
                final period = hourInt >= 12 ? 'PM' : 'AM';
                final displayHour = hourInt > 12 ? hourInt - 12 : (hourInt == 0 ? 12 : hourInt);

                final code = hourly.weatherCodes[hourIndex] ?? 0;
                final isDay = hourly.isDay?[hourIndex] ?? 1;
                final info = WeatherUtils.getWeatherInfo(code, isDay, lang);

                return TimelineItem(
                  time: '$displayHour $period',
                  emoji: info.iconEmoji,
                  status: info.description.split(' ').first.toUpperCase(),
                );
              });

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutdoorCard(
                  activity: act['name']!,
                  suggestion: suggestion,
                  suggestionIcon: suggestionIcon,
                  status: status,
                  statusMessage: statusDetail,
                  timeline: timeline,
                  activityIcon: act['icon']!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSolarCycle(WeatherResponse weather) {
    final daily = weather.daily;
    final now = DateTime.now();
    final fallbackTimeStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SolarArcWidget(
        sunrise: daily.sunrise != null && daily.sunrise!.isNotEmpty ? (daily.sunrise![0] ?? '2026-10-01T06:00') : '2026-10-01T06:00',
        sunset: daily.sunset != null && daily.sunset!.isNotEmpty ? (daily.sunset![0] ?? '2026-10-01T18:00') : '2026-10-01T18:00',
        currentTime: weather.current?.time ?? fallbackTimeStr,
      ),
    );
  }

  Widget _buildDailyForecast(WeatherResponse weather, String cityName, String lang) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weather.daily.time.length,
        itemBuilder: (context, index) {
          final date = DateTime.parse(weather.daily.time[index]);
          final dayName = index == 0 ? 'Today' : DateFormat('E').format(date);
          final max = weather.daily.maxTemp[index] ?? 0;
          final min = weather.daily.minTemp[index] ?? 0;
          final code = weather.daily.weatherCodes[index] ?? 0;
          final emoji = WeatherUtils.getWeatherInfo(code, 1, lang).iconEmoji;

          return GestureDetector(
            onTap: () => context.push('/daily-details', extra: {
              'weather': weather,
              'dayIndex': index,
              'cityName': cityName,
            }),
            child: Hero(
              tag: 'daily-card-$index',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dayName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        const Spacer(),
                        Text(
                          '${max.toInt()}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${min.toInt()}°',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCitySearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CitySearchSheet(),
    );
  }
}

class CitySearchSheet extends ConsumerWidget {
  const CitySearchSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) => GlassCard(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: LocalizationService.translate('search_city', ref.watch(settingsProvider).languageCode),
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).set(val);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final query = ref.watch(searchQueryProvider);
                  final resultsAsync = ref.watch(citySearchProvider(query));

                  return resultsAsync.when(
                    data: (res) {
                      final results = res.results ?? [];
                      final recent = ref.watch(recentLocationsProvider);

                      if (query.isEmpty && recent.isNotEmpty) {
                        final lang = ref.watch(settingsProvider).languageCode;
                        return ListView(
                          controller: controller,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                LocalizationService.translate('recent_searches', lang),
                                style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...recent.map((city) => ListTile(
                                  leading: const Icon(Icons.history, color: Colors.white38),
                                  title: Text(city.name, style: const TextStyle(color: Colors.white)),
                                  subtitle: Text('${city.admin1 ?? ""}, ${city.country}', style: const TextStyle(color: Colors.white54)),
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    ref.read(selectedLocationProvider.notifier).set(city);
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                        );
                      }

                      return ListView.builder(
                        controller: controller,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final city = results[index];
                          return ListTile(
                            title: Text(city.name, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              '${city.admin1 ?? ""}, ${city.country}',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref.read(recentLocationsProvider.notifier).add(city);
                              ref.read(selectedLocationProvider.notifier).set(city);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white70))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
