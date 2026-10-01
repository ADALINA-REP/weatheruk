import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/ad_banner.dart';
import '../../data/models/weather_models.dart';
import '../widgets/weather_background.dart';
import '../../core/localization_service.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.languageCode;
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(citySearchProvider(searchQuery));

    final selectedLocation = ref.watch(selectedLocationProvider);
    final lat = selectedLocation.latitude;
    final lon = selectedLocation.longitude;
    final weatherAsync = ref.watch(weatherProvider((lat: lat, lon: lon)));
    
    final famousCities = [
      'London', 'Manchester', 'Birmingham', 'Edinburgh', 'Glasgow', 
      'Liverpool', 'Belfast', 'Bristol', 'Leeds', 'Cardiff'
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: weatherAsync.when(
        data: (weather) => WeatherBackground(
          weatherCode: weather.current!.weatherCode,
          isDay: weather.current!.isDay,
          precipitation: weather.current!.precipitation ?? 0.0,
          rainProb: 0,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(weatherProvider((lat: lat, lon: lon)));
              if (searchQuery.isNotEmpty) {
                ref.invalidate(citySearchProvider(searchQuery));
              }
              return ref.read(weatherProvider((lat: lat, lon: lon)).future);
            },
            backgroundColor: const Color(0xFF151F38),
            color: const Color(0xFF0170E3),
            child: SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(context, lang),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildSearchBar(context, ref, lang),
                          const SizedBox(height: 16),
                          const AdBanner(),
                          const SizedBox(height: 24),
                          Text(
                            searchQuery.isEmpty 
                              ? LocalizationService.translate('popular_cities', lang)
                              : LocalizationService.translate('search_cities', lang),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  if (searchQuery.isEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildCityTile(context, ref, famousCities[index]),
                        ),
                        childCount: famousCities.length,
                      ),
                    )
                  else
                    searchResults.when(
                      data: (data) {
                        final list = data.results ?? [];
                        if (list.isEmpty) {
                          return SliverFillRemaining(
                            child: Center(child: Text(LocalizationService.translate('fav_no_items', lang), style: const TextStyle(color: Colors.white54))),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildResultTile(context, ref, list[index]),
                            ),
                            childCount: list.length,
                          ),
                        );
                      },
                      loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF0170E3)))),
                      error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)))),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 220)),
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white24)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String lang) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 80,
      floating: true,
      pinned: false,
      automaticallyImplyLeading: false,
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'WeatherUK ',
              style: TextStyle(
                color: Color(0xFF0170E3),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: 'Radar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref, String lang) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF0170E3)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: LocalizationService.translate('search_city', lang),
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).set(val);
              },
            ),
          ),
          const Icon(Icons.search, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, WidgetRef ref, GeocodingResult city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(selectedLocationProvider.notifier).set(city);
            ref.read(searchQueryProvider.notifier).set('');
            context.go('/');
          },
          child: Row(
            children: [
              const Icon(Icons.location_city, color: Color(0xFF0170E3), size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${city.admin1 ?? city.country}',
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityTile(BuildContext context, WidgetRef ref, String cityName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: InkWell(
          onTap: () async {
            HapticFeedback.mediumImpact();
            final results = await ref.read(citySearchProvider(cityName).future);
            if (results.results != null && results.results!.isNotEmpty) {
              final city = results.results!.first;
              ref.read(selectedLocationProvider.notifier).set(city);
              ref.read(searchQueryProvider.notifier).set('');
              context.go('/');
            }
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_city, color: Colors.white70),
              ),
              const SizedBox(width: 16),
              Text(
                cityName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
