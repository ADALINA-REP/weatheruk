import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/weather_background.dart';
import '../../core/localization_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final lang = settings.languageCode;

    final selectedLocation = ref.watch(selectedLocationProvider);
    final lat = selectedLocation.latitude;
    final lon = selectedLocation.longitude;
    final weatherAsync = ref.watch(weatherProvider((lat: lat, lon: lon)));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: weatherAsync.when(
        data: (weather) => WeatherBackground(
          weatherCode: weather.current!.weatherCode,
          isDay: weather.current!.isDay,
          precipitation: weather.current!.precipitation ?? 0.0,
          rainProb: 0,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context, lang),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionLabel(LocalizationService.translate('units', lang)),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              title: settings.unit == TemperatureUnit.celsius 
                                ? LocalizationService.translate('unit_celsius', lang)
                                : LocalizationService.translate('unit_fahrenheit', lang),
                              value: settings.unit == TemperatureUnit.celsius,
                              onChanged: (_) => notifier.toggleUnit(),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: settings.pressureUnit == 'mb'
                                ? LocalizationService.translate('pressure_unit_mb', lang)
                                : LocalizationService.translate('pressure_unit_hpa', lang),
                              value: settings.pressureUnit == 'hPa',
                              onChanged: (val) => notifier.togglePressureUnit(),
                            ),
                          ],
                        ),
                      ),
                      
                      _buildSectionLabel(LocalizationService.translate('customization', lang)),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(LocalizationService.translate('language', lang), style: const TextStyle(color: Colors.white, fontSize: 16)),
                              subtitle: Text(settings.language, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                              trailing: const Icon(Icons.language, color: Color(0xFF0170E3)), 
                              onTap: () => _showLanguageSelector(context, ref),
                            ),
                          ],
                        ),
                      ),
                      
                      _buildSectionLabel(LocalizationService.translate('support', lang)),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            const ListTile(
                              title: Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 16)),
                              subtitle: Text('Privacy & Data Protection Notice', style: TextStyle(color: Colors.white38, fontSize: 12)),
                              trailing: Icon(Icons.privacy_tip_outlined, color: Colors.lightBlueAccent),
                            ),
                            _buildDivider(),
                            const ListTile(
                              title: Text('Support & Feedback', style: TextStyle(color: Colors.white, fontSize: 16)),
                              subtitle: Text('weatheruk.support@siscom.info', style: TextStyle(color: Colors.white38, fontSize: 12)),
                              trailing: Icon(Icons.help_outline, color: Colors.greenAccent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 220),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final languages = [
      {'name': 'English', 'code': 'en', 'flag': '🇬🇧'},
      {'name': 'Español', 'code': 'es', 'flag': '🇪🇸'},
      {'name': 'Français', 'code': 'fr', 'flag': '🇫🇷'},
      {'name': 'Deutsch', 'code': 'de', 'flag': '🇩🇪'},
      {'name': 'Italiano', 'code': 'it', 'flag': '🇮🇹'},
      {'name': 'العربية', 'code': 'ar', 'flag': '🇸🇦'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Color(0xFF151F38),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = settings.languageCode == lang['code'];
                    
                    return GestureDetector(
                      onTap: () {
                        ref.read(settingsProvider.notifier).setLanguage(lang['name']!, lang['code']!);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0170E3).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0170E3) : Colors.white.withOpacity(0.1),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 16),
                            Text(
                              lang['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Color(0xFF0170E3)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFF0170E3),
      inactiveTrackColor: Colors.white10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 16,
      endIndent: 16,
    );
  }
}
