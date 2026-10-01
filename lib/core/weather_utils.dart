import 'package:flutter/material.dart';
import 'localization_service.dart';

enum WeatherState { sunny, rain, cloudy, night, snow, storm, fog, drizzle }

class WeatherInfo {
  final String description;
  final String iconEmoji;
  final WeatherState state;
  final String backgroundName;

  WeatherInfo({
    required this.description,
    required this.iconEmoji,
    required this.state,
    required this.backgroundName,
  });
}

class WeatherUtils {
  static String formatTemperature(double temp, {bool isCelsius = true}) {
    if (isCelsius) {
      return '${temp.toInt()}°C';
    } else {
      final fahrenheit = (temp * 9 / 5) + 32;
      return '${fahrenheit.toInt()}°F';
    }
  }

  static int getCurrentHourIndex(List<String> times) {
    final now = DateTime.now();
    final nowIso = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}';
    
    for (int i = 0; i < times.length; i++) {
      if (times[i].startsWith(nowIso)) {
        return i;
      }
    }
    return 0;
  }

  static WeatherState mapWeatherCode(int code, int isDay) {
    if (isDay == 0) return WeatherState.night;
    switch (code) {
      case 0:
      case 1:
        return WeatherState.sunny;
      case 2:
      case 3:
        return WeatherState.cloudy;
      case 45:
      case 48:
        return WeatherState.fog;
      case 51:
      case 53:
      case 55:
        return WeatherState.drizzle;
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return WeatherState.rain;
      case 95:
      case 96:
      case 99:
        return WeatherState.storm;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherState.snow;
      default:
        return WeatherState.sunny;
    }
  }

  static WeatherInfo getWeatherInfo(int code, int isDay, [String langCode = 'en']) {
    final state = mapWeatherCode(code, isDay);
    final isNight = isDay == 0;

    switch (code) {
      case 0:
        return WeatherInfo(
          description: LocalizationService.translate(isNight ? 'clear_sky' : 'sunny', langCode),
          iconEmoji: isNight ? '🌙' : '☀️',
          state: state,
          backgroundName: isNight ? 'bg_clear_night' : 'bg_clear_day',
        );
      case 1:
        return WeatherInfo(
          description: LocalizationService.translate(isNight ? 'mainly_clear' : 'mostly_sunny', langCode),
          iconEmoji: isNight ? '🌙' : '☀️',
          state: state,
          backgroundName: isNight ? 'bg_clear_night' : 'bg_mainly_clear_day',
        );
      case 2:
        return WeatherInfo(
          description: LocalizationService.translate('partly_cloudy', langCode),
          iconEmoji: isNight ? '☁️' : '⛅',
          state: state,
          backgroundName: isNight ? 'bg_partly_cloudy_night' : 'bg_partly_cloudy_day',
        );
      case 3:
        return WeatherInfo(
          description: LocalizationService.translate('overcast', langCode),
          iconEmoji: '☁️',
          state: state,
          backgroundName: 'bg_overcast',
        );
      case 45:
      case 48:
        return WeatherInfo(
          description: LocalizationService.translate('foggy', langCode),
          iconEmoji: '🌫️',
          state: WeatherState.fog,
          backgroundName: 'bg_fog',
        );
      case 56:
      case 57:
        return WeatherInfo(
          description: LocalizationService.translate('light_freezing_drizzle', langCode),
          iconEmoji: '🌧️',
          state: WeatherState.drizzle,
          backgroundName: 'bg_drizzle',
        );
      case 51:
      case 53:
      case 55:
        return WeatherInfo(
          description: LocalizationService.translate('light_drizzle', langCode),
          iconEmoji: '🌦️',
          state: WeatherState.drizzle,
          backgroundName: 'bg_drizzle',
        );
      case 61:
      case 63:
      case 65:
        return WeatherInfo(
          description: LocalizationService.translate('moderate_rain', langCode),
          iconEmoji: '🌧️',
          state: WeatherState.rain,
          backgroundName: 'bg_rain',
        );
      case 66:
      case 67:
        return WeatherInfo(
          description: LocalizationService.translate('light_freezing_rain', langCode),
          iconEmoji: '🌧️',
          state: WeatherState.rain,
          backgroundName: 'bg_rain',
        );
      case 80:
      case 81:
      case 82:
        return WeatherInfo(
          description: LocalizationService.translate('light_rain_showers', langCode),
          iconEmoji: '🌦️',
          state: WeatherState.rain,
          backgroundName: 'bg_rain',
        );
      case 71:
      case 73:
      case 75:
        return WeatherInfo(
          description: LocalizationService.translate('light_snow', langCode),
          iconEmoji: '❄️',
          state: WeatherState.snow,
          backgroundName: 'bg_snow',
        );
      case 77:
        return WeatherInfo(
          description: LocalizationService.translate('snow_grains', langCode),
          iconEmoji: '❄️',
          state: WeatherState.snow,
          backgroundName: 'bg_snow',
        );
      case 85:
      case 86:
        return WeatherInfo(
          description: LocalizationService.translate('light_snow_showers', langCode),
          iconEmoji: '🌨️',
          state: WeatherState.snow,
          backgroundName: 'bg_snow',
        );
      case 95:
      case 96:
      case 99:
        return WeatherInfo(
          description: LocalizationService.translate('thunderstorm', langCode),
          iconEmoji: '⛈️',
          state: WeatherState.storm,
          backgroundName: 'bg_thunderstorm',
        );
      default:
        return WeatherInfo(
          description: LocalizationService.translate('partly_cloudy', langCode),
          iconEmoji: '☁️',
          state: WeatherState.cloudy,
          backgroundName: 'bg_partly_cloudy_day',
        );
    }
  }

  static String getWindDirection(int degree) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((degree % 360) / 22.5).round();
    return directions[index % 16];
  }

  static Map<String, dynamic> calculateOutdoorScore(double temp, double windSpeed, int rainProb, [String langCode = 'en']) {
    int score = 10;
    
    if (temp < 15 || temp > 25) score -= 2;
    if (temp < 5 || temp > 32) score -= 3;
    if (windSpeed > 20) score -= 2;
    if (windSpeed > 45) score -= 3;
    if (rainProb > 20) score -= 3;
    if (rainProb > 60) score -= 4;

    score = score.clamp(1, 10);
    
    String message = LocalizationService.translate('excellent', langCode);
    if (score < 8) message = LocalizationService.translate('good', langCode);
    if (score < 5) message = LocalizationService.translate('moderate', langCode);
    if (score < 3) message = LocalizationService.translate('poor', langCode);

    return {'score': score, 'message': message};
  }

  static String getAqiDescription(int aqi, [String langCode = 'en']) {
    if (aqi <= 50) return LocalizationService.translate('excellent', langCode);
    if (aqi <= 100) return LocalizationService.translate('good', langCode);
    if (aqi <= 150) return LocalizationService.translate('moderate', langCode);
    if (aqi <= 200) return LocalizationService.translate('poor', langCode);
    if (aqi <= 300) return LocalizationService.translate('very_poor', langCode);
    return LocalizationService.translate('hazard_alerts', langCode);
  }

  static Color getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.lightGreen;
    if (aqi <= 150) return Colors.yellow;
    if (aqi <= 200) return Colors.orange;
    if (aqi <= 300) return Colors.red;
    return Colors.purple;
  }

  static LinearGradient getBackgroundGradient(int code, int isDay, {double? precipitation, int? rainProb}) {
    final info = getWeatherInfo(code, isDay);
    final isNight = isDay == 0;

    if (isNight) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E293B),
        ],
      );
    }

    switch (info.state) {
      case WeatherState.sunny:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0170E3),
            Color(0xFF06B6D4),
          ],
        );
      case WeatherState.cloudy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF151F38),
            Color(0xFF1E293B),
          ],
        );
      case WeatherState.rain:
      case WeatherState.drizzle:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
        );
      case WeatherState.storm:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
          ],
        );
      case WeatherState.snow:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF334155),
            Color(0xFF64748B),
          ],
        );
      case WeatherState.fog:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF475569),
            Color(0xFF64748B),
          ],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0170E3), Color(0xFF06B6D4)],
        );
    }
  }
}
