import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weather_models.dart';
import '../../data/api/open_meteo_service.dart';
import '../../core/cache_service.dart';

final weatherProvider = FutureProvider.family<WeatherResponse, ({double lat, double lon})>((ref, arg) async {
  final apiService = OpenMeteoService();
  
  final cachedData = await CacheService.getCachedWeather(arg.lat, arg.lon);
  if (cachedData != null) {
    return WeatherResponse.fromJson(cachedData);
  }

  return apiService.getWeather(arg.lat, arg.lon);
});

final airQualityProvider = FutureProvider.family<AirQualityResponse, ({double lat, double lon})>((ref, arg) async {
  final apiService = OpenMeteoService();

  final cachedData = await CacheService.getCachedAqi(arg.lat, arg.lon);
  if (cachedData != null) {
    return AirQualityResponse.fromJson(cachedData);
  }

  return apiService.getAirQuality(arg.lat, arg.lon);
});
