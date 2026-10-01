import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/weather_models.dart';
import '../../core/weather_utils.dart';
import '../../core/localization_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/ad_banner.dart';
import '../widgets/weather_background.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';

class WeatherDetailsScreen extends ConsumerStatefulWidget {
  final double lat;
  final double lon;
  final String cityName;

  const WeatherDetailsScreen({
    super.key,
    required this.lat,
    required this.lon,
    required this.cityName,
  });

  @override
  ConsumerState<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends ConsumerState<WeatherDetailsScreen> {
  int _selectedMetric = 0;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(settingsProvider).languageCode;
    final weatherAsync = ref.watch(weatherProvider((lat: widget.lat, lon: widget.lon)));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: weatherAsync.when(
        data: (weather) => WeatherBackground(
          weatherCode: weather.current!.weatherCode,
          isDay: weather.current!.isDay,
          precipitation: weather.current!.precipitation ?? 0.0,
          rainProb: weather.hourly.precipitationProbability[0] ?? 0,
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(weatherProvider((lat: widget.lat, lon: widget.lon)));
                return ref.read(weatherProvider((lat: widget.lat, lon: widget.lon)).future);
              },
              backgroundColor: const Color(0xFF151F38),
              color: const Color(0xFF0170E3),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(lang),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCurrentStats(weather, lang),
                          const SizedBox(height: 32),
                          _buildMetricSelector(lang),
                          const SizedBox(height: 24),
                          _buildChartContainer(weather, lang),
                          const SizedBox(height: 24),
                          const AdBanner(),
                          const SizedBox(height: 24),
                          _buildExtraDetails(weather, lang),
                          const SizedBox(height: 220),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildAppBar(String lang) {
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

  Widget _buildCurrentStats(WeatherResponse weather, String lang) {
    final current = weather.current!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMiniStat(LocalizationService.translate('humidity', lang), '${current.humidity}%', Icons.water_drop, Colors.blue),
          const SizedBox(width: 16),
          _buildMiniStat(LocalizationService.translate('pressure', lang), '${current.surfacePressure?.toInt()} hPa', Icons.compress, Colors.purple),
          const SizedBox(width: 16),
          _buildMiniStat(
            LocalizationService.translate('feels_like', lang),
            WeatherUtils.formatTemperature(
              current.feelsLike,
              isCelsius: ref.watch(settingsProvider).unit == TemperatureUnit.celsius,
            ),
            Icons.thermostat,
            Colors.redAccent,
          ),
          const SizedBox(width: 16),
          _buildMiniStat(LocalizationService.translate('wind', lang), '${current.windSpeed} km/h', Icons.air, Colors.teal),
          const SizedBox(width: 16),
          _buildMiniStat(LocalizationService.translate('uv_index', lang), '${weather.daily.uvIndexMax?[0] ?? 0}', Icons.wb_sunny, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value, 
          style: const TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 16, 
            color: Colors.white,
          )
        ),
        Text(
          label, 
          style: TextStyle(
            color: Colors.white.withOpacity(0.9), 
            fontSize: 11, 
            fontWeight: FontWeight.w700,
          )
        ),
      ],
    );
  }

  Widget _buildMetricSelector(String lang) {
    final metrics = [
      LocalizationService.translate('humidity', lang),
      LocalizationService.translate('pressure', lang),
      LocalizationService.translate('wind', lang),
      LocalizationService.translate('uv_index', lang),
      LocalizationService.translate('rain', lang),
    ];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedMetric == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedMetric = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0170E3) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0170E3) : Colors.white10,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                metrics[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartContainer(WeatherResponse weather, String lang) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '24-Hour ${_getMetricName(lang)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: _buildChart(weather),
          ),
        ],
      ),
    );
  }

  String _getMetricName(String lang) {
    switch (_selectedMetric) {
      case 0: return LocalizationService.translate('humidity', lang);
      case 1: return LocalizationService.translate('pressure', lang);
      case 2: return LocalizationService.translate('wind', lang);
      case 3: return LocalizationService.translate('uv_index', lang);
      case 4: return LocalizationService.translate('rain', lang);
      default: return '';
    }
  }

  Widget _buildChart(WeatherResponse weather) {
    final List<double> data = _getChartData(weather);
    final Color chartColor = _getChartColor();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 6,
              getTitlesWidget: (value, meta) {
                final startIndex = WeatherUtils.getCurrentHourIndex(weather.hourly.time);
                final hour = (startIndex + value.toInt()) % 24;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${hour}h',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getInterval(),
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            gradient: LinearGradient(colors: [chartColor, chartColor.withOpacity(0.3)]),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [chartColor.withOpacity(0.2), chartColor.withOpacity(0.01)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getChartData(WeatherResponse weather) {
    final hourly = weather.hourly;
    final startIndex = WeatherUtils.getCurrentHourIndex(hourly.time);
    
    switch (_selectedMetric) {
      case 0: return (hourly.humidity ?? []).skip(startIndex).take(24).map((e) => e?.toDouble() ?? 0.0).toList();
      case 1: return (hourly.surfacePressure ?? []).skip(startIndex).take(24).map((e) => e ?? 0.0).toList();
      case 2: return (hourly.windSpeeds ?? []).skip(startIndex).take(24).map((e) => e ?? 0.0).toList();
      case 3: return (hourly.uvIndex ?? List.filled(hourly.time.length, 0.0)).skip(startIndex).take(24).map((e) => e ?? 0.0).toList();
      case 4: return (hourly.precipitation ?? List.filled(hourly.time.length, 0.0)).skip(startIndex).take(24).map((e) => e ?? 0.0).toList();
      default: return List.filled(24, 0.0);
    }
  }

  double _getInterval() {
    switch (_selectedMetric) {
      case 0: return 20;
      case 1: return 5;
      case 2: return 10;
      case 3: return 1;
      case 4: return 1;
      default: return 10;
    }
  }

  Color _getChartColor() {
    switch (_selectedMetric) {
      case 0: return Colors.blue;
      case 1: return Colors.purple;
      case 2: return Colors.teal;
      case 3: return Colors.orange;
      case 4: return Colors.blueAccent.shade100;
      default: return Colors.blueAccent;
    }
  }

  Widget _buildExtraDetails(WeatherResponse weather, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.translate('daily_insights', lang),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildInsightRow(
          LocalizationService.translate('sun_title', lang).split('&').first.trim(), 
          weather.daily.sunrise?[0]?.split('T')[1] ?? '--:--', 
          Icons.wb_twilight, 
          Colors.amber,
        ),
        _buildInsightRow(
          LocalizationService.translate('sun_title', lang).split('&').last.trim(), 
          weather.daily.sunset?[0]?.split('T')[1] ?? '--:--', 
          Icons.nights_stay, 
          Colors.deepOrange,
        ),
        _buildInsightRow(
          LocalizationService.translate('wind', lang), 
          '${weather.daily.windSpeedMax?[0]} km/h', 
          Icons.speed, 
          Colors.cyan,
        ),
      ],
    );
  }

  Widget _buildInsightRow(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white70)),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
