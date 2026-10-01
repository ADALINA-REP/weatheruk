import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static Future<void> cacheWeather(dynamic data, double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_${lat}_$lon', json.encode(data));
    } catch (e) {
      print('Error caching weather: $e');
    }
  }

  static Future<dynamic> getCachedWeather(double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString('weather_${lat}_$lon');
      if (content != null) {
        return json.decode(content);
      }
    } catch (e) {
      print('Error reading weather cache: $e');
    }
    return null;
  }

  static Future<void> cacheAqi(dynamic data, double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aqi_${lat}_$lon', json.encode(data));
    } catch (e) {
      print('Error caching AQI: $e');
    }
  }

  static Future<dynamic> getCachedAqi(double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString('aqi_${lat}_$lon');
      if (content != null) {
        return json.decode(content);
      }
    } catch (e) {
      print('Error reading AQI cache: $e');
    }
    return null;
  }
}
