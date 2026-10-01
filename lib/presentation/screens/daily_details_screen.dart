import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/weather_utils.dart';
import '../../core/localization_service.dart';
import '../../data/models/weather_models.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_weather_icon.dart';
import '../widgets/outdoor_card.dart';
import '../widgets/weather_background.dart';
import '../widgets/solar_arc_widget.dart';
import '../widgets/ad_banner.dart';
import '../providers/settings_provider.dart';
import 'package:intl/intl.dart';

class DailyDetailsScreen extends ConsumerStatefulWidget {
  final WeatherResponse weather;
  final int dayIndex;
  final String cityName;

  const DailyDetailsScreen({
    super.key,
    required this.weather,
    required this.dayIndex,
    required this.cityName,
  });

  @override
  ConsumerState<DailyDetailsScreen> createState() => _DailyDetailsScreenState();
}

class _DailyDetailsScreenState extends ConsumerState<DailyDetailsScreen> {
  int _selectedMetric = 0;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(settingsProvider).languageCode;
    final daily = widget.weather.daily;
    final code = daily.weatherCodes[widget.dayIndex] ?? 0;
    
    final startHour = widget.dayIndex * 24;
    final endHour = startHour + 24;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: WeatherBackground(
        weatherCode: code,
        isDay: 1, 
        precipitation: daily.precipitationSum?[widget.dayIndex] ?? 0.0,
        rainProb: daily.precipitationProbabilityMax?[widget.dayIndex] ?? 0,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context, lang),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildDaySummary(ref, lang),
                      const SizedBox(height: 32),
                      _buildSectionHeader(LocalizationService.translate('forecast_hourly', lang)),
                      const SizedBox(height: 12),
                      _buildHourlyForecast(ref, startHour, endHour, lang),
                      const SizedBox(height: 32),
                      _buildSectionHeader(LocalizationService.translate('analytics_insights', lang)),
                      _buildMetricSelector(lang),
                      const SizedBox(height: 16),
                      _buildChartContainer(lang, startHour),
                      const SizedBox(height: 32),
                      _buildDetailedStats(lang),
                      const SizedBox(height: 32),
                      const AdBanner(),
                      const SizedBox(height: 16),
                      _buildOutdoorSection(ref, startHour, widget.dayIndex, lang),
                      const SizedBox(height: 220),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildDaySummary(WidgetRef ref, String lang) {
    final daily = widget.weather.daily;
    final code = daily.weatherCodes[widget.dayIndex] ?? 0;
    final info = WeatherUtils.getWeatherInfo(code, 1, lang);
    final isCelsius = ref.watch(settingsProvider).unit == TemperatureUnit.celsius;

    final rawDate = daily.time[widget.dayIndex];
    final parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    final isToday = widget.dayIndex == 0;
    final dateLabel = isToday
        ? 'Today, ${DateFormat('MMM d').format(parsedDate)}'
        : DateFormat('EEEE, MMM d').format(parsedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DynamicWeatherIcon(
              code: code,
              isDay: 1,
              size: 70,
              precipitation: daily.precipitationSum?[widget.dayIndex],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cityName,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          WeatherUtils.formatTemperature(daily.maxTemp[widget.dayIndex] ?? 0.0, isCelsius: isCelsius),
          style: const TextStyle(
            fontSize: 88,
            fontWeight: FontWeight.w900,
            letterSpacing: -4,
            color: Colors.white,
          ),
        ),
        Text(
          info.description.toUpperCase(),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMiniStat(Icons.water_drop_outlined, '${daily.precipitationProbabilityMax?[widget.dayIndex] ?? 0}%', 'Rain'),
            const SizedBox(width: 28),
            _buildMiniStat(Icons.air_outlined, '${daily.windSpeedMax?[widget.dayIndex]?.toInt() ?? 0} km/h', 'Wind'),
            const SizedBox(width: 28),
            _buildMiniStat(Icons.wb_sunny_outlined, 'UV ${daily.uvIndexMax?[widget.dayIndex]?.toStringAsFixed(1) ?? '0'}', 'UV'),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.white),
        const SizedBox(height: 6),
        Text(
          value, 
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.w900,
          )
        ),
        Text(
          label, 
          style: TextStyle(
            color: Colors.white.withOpacity(0.9), 
            fontSize: 11, 
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          )
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(WidgetRef ref, int start, int end, String lang) {
    return SizedBox(
      height: 135,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        itemBuilder: (context, index) {
          final globalIndex = start + index;
          if (globalIndex >= widget.weather.hourly.time.length) return const SizedBox();

          final time = widget.weather.hourly.time[globalIndex].split('T')[1].substring(0, 5);
          final temp = widget.weather.hourly.temperatures[globalIndex] ?? 0;
          final code = widget.weather.hourly.weatherCodes[globalIndex] ?? 0;
          final isDay = widget.weather.hourly.isDay?[globalIndex] ?? 1;
          final emoji = WeatherUtils.getWeatherInfo(code, isDay, lang).iconEmoji;
          final rainProb = widget.weather.hourly.precipitationProbability[globalIndex] ?? 0;

          return Container(
            width: 75,
            margin: const EdgeInsets.only(right: 12),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                children: [
                  Text(time, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Text(
                    WeatherUtils.formatTemperature(
                      temp,
                      isCelsius: ref.watch(settingsProvider).unit == TemperatureUnit.celsius,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop, size: 10, color: Colors.white),
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

  Widget _buildMetricSelector(String lang) {
    final metrics = [
      {'label': 'Temp', 'icon': Icons.thermostat},
      {'label': 'Precip %', 'icon': Icons.water_drop},
      {'label': 'Wind', 'icon': Icons.air},
      {'label': 'UV Index', 'icon': Icons.wb_sunny},
      {'label': 'Humidity', 'icon': Icons.opacity},
      {'label': 'Pressure', 'icon': Icons.speed},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedMetric == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(metrics[index]['label'] as String),
              avatar: Icon(metrics[index]['icon'] as IconData, size: 14, color: isSelected ? Colors.white : Colors.white38),
              onSelected: (val) => setState(() => _selectedMetric = index),
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: const Color(0xFF0170E3).withOpacity(0.4),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isSelected ? const Color(0xFF0170E3) : Colors.white10),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartContainer(String lang, int startHour) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationService.translate('trend_24h', lang),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              Text(
                '${widget.weather.daily.time[widget.dayIndex]}',
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: _buildChart(startHour),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(int startHour) {
    final List<double> data = _getChartData(startHour);
    final Color chartColor = _getChartColor();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 6,
              getTitlesWidget: (value, meta) {
                final hour = (value.toInt()) % 24;
                return Text('${hour}h', style: const TextStyle(color: Colors.white38, fontSize: 9));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getInterval(),
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white38, fontSize: 9)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: chartColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [chartColor.withOpacity(0.2), chartColor.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getChartData(int startHour) {
    final hourly = widget.weather.hourly;
    switch (_selectedMetric) {
      case 0: return (hourly.temperatures).skip(startHour).take(24).map((e) => e ?? 0.0).toList();
      case 1: return (hourly.precipitationProbability).skip(startHour).take(24).map((e) => e?.toDouble() ?? 0.0).toList();
      case 2: return (hourly.windSpeeds ?? []).skip(startHour).take(24).map((e) => e ?? 0.0).toList();
      case 3: return (hourly.uvIndex ?? []).skip(startHour).take(24).map((e) => e ?? 0.0).toList();
      case 4: return (hourly.humidity ?? []).skip(startHour).take(24).map((e) => (e ?? 0).toDouble()).toList();
      case 5: return (hourly.surfacePressure ?? []).skip(startHour).take(24).map((e) => e ?? 0.0).toList();
      default: return List.filled(24, 0.0);
    }
  }

  double _getInterval() {
    switch (_selectedMetric) {
      case 0: return 10;
      case 1: return 25;
      case 2: return 15;
      case 3: return 3;
      case 4: return 20;
      case 5: return 5;
      default: return 10;
    }
  }

  Color _getChartColor() {
    switch (_selectedMetric) {
      case 0: return Colors.orangeAccent;
      case 1: return Colors.blueAccent;
      case 2: return Colors.tealAccent;
      case 3: return Colors.yellowAccent;
      case 4: return Colors.purpleAccent;
      case 5: return Colors.cyanAccent;
      default: return Colors.white;
    }
  }

  Widget _buildDetailedStats(String lang) {
    final daily = widget.weather.daily;
    final now = DateTime.now();
    final fallbackTimeStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentTime = widget.weather.current?.time ?? fallbackTimeStr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(LocalizationService.translate('solar_cycle', lang)),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SolarArcWidget(
            sunrise: daily.sunrise?[widget.dayIndex] ?? '2024-01-01T06:00',
            sunset: daily.sunset?[widget.dayIndex] ?? '2024-01-01T18:00',
            currentTime: currentTime,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(LocalizationService.translate('additional_data', lang)),
        _buildStatRow(LocalizationService.translate('max_wind', lang), '${daily.windSpeedMax?[widget.dayIndex]} km/h', Icons.air, Colors.cyan),
        _buildStatRow(LocalizationService.translate('precip_sum', lang), '${daily.precipitationSum?[widget.dayIndex]} mm', Icons.water, Colors.blue),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildOutdoorSection(WidgetRef ref, int startHour, int index, String lang) {
    final maxTemp = widget.weather.daily.maxTemp[index] ?? 0;
    final wind = widget.weather.daily.windSpeedMax?[index] ?? 0;
    final precip = widget.weather.daily.precipitationProbabilityMax?[index] ?? 0;

    final activities = [
      {'name': LocalizationService.translate('sport_running', lang), 'icon': '🏃'},
      {'name': LocalizationService.translate('sport_cycling', lang), 'icon': '🚴'},
      {'name': LocalizationService.translate('sport_hiking', lang), 'icon': '🥾'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(LocalizationService.translate('sport_outdoor', lang)),
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: activities.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, actIndex) {
              final act = activities[actIndex];
              
              String suggestion = LocalizationService.translate('smart_great_day', lang);
              String suggestionIcon = '✨';
              if (maxTemp < 10) {
                suggestion = LocalizationService.translate('smart_dress_warm', lang);
                suggestionIcon = '❄️';
              } else if (maxTemp > 30) {
                suggestion = LocalizationService.translate('smart_hydration', lang);
                suggestionIcon = '💧';
              } else if (precip > 20) {
                suggestion = LocalizationService.translate('smart_stay_indoors', lang);
                suggestionIcon = '🏠';
              }

              final scoreData = WeatherUtils.calculateOutdoorScore(maxTemp, wind, precip, lang);
              final status = scoreData['message'] as String;

              final timeline = List.generate(24, (i) {
                final hIdx = startHour + i;
                if (hIdx >= widget.weather.hourly.time.length) {
                   return TimelineItem(time: '--', emoji: '❓', status: 'N/A');
                }
                final fullTime = widget.weather.hourly.time[hIdx].split('T')[1].substring(0, 5);
                final hourInt = int.parse(fullTime.substring(0, 2));
                final period = hourInt >= 12 ? 'PM' : 'AM';
                final displayHour = hourInt > 12 ? hourInt - 12 : (hourInt == 0 ? 12 : hourInt);
                
                final hCode = widget.weather.hourly.weatherCodes[hIdx] ?? 0;
                final hIsDay = widget.weather.hourly.isDay?[hIdx] ?? 1;
                final hInfo = WeatherUtils.getWeatherInfo(hCode, hIsDay, lang);
                
                return TimelineItem(
                  time: '$displayHour $period',
                  emoji: hInfo.iconEmoji,
                  status: hInfo.description.split(' ').first.toUpperCase(),
                );
              });

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutdoorCard(
                  activity: act['name']!,
                  suggestion: suggestion,
                  suggestionIcon: suggestionIcon,
                  status: 'FORECAST',
                  statusMessage: status,
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
}
