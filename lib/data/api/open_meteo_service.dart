import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';
import '../../core/cache_service.dart';

class OpenMeteoService {
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _airQualityBaseUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';

  Future<GeocodingResponse> searchCity(String name, {int count = 5, String language = 'en'}) async {
    final url = Uri.parse('$_geocodingBaseUrl?name=$name&count=$count&language=$language&format=json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return GeocodingResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load geocoding data');
    }
  }

  Future<WeatherResponse> getWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_forecastBaseUrl?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,precipitation'
      '&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,visibility,is_day,surface_pressure,precipitation,wind_speed_10m,uv_index'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max,wind_speed_10m_max,apparent_temperature_max,precipitation_sum'
      '&timezone=auto'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await CacheService.cacheWeather(data, lat, lon);
      return WeatherResponse.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<AirQualityResponse> getAirQuality(double lat, double lon) async {
    final url = Uri.parse(
      '$_airQualityBaseUrl?latitude=$lat&longitude=$lon'
      '&current=european_aqi,us_aqi,pm2_5,pm10,carbon_monoxide,nitrogen_dioxide,ozone,sulphur_dioxide'
      '&hourly=european_aqi'
      '&timezone=auto'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await CacheService.cacheAqi(data, lat, lon);
      return AirQualityResponse.fromJson(data);
    } else {
      throw Exception('Failed to load air quality data');
    }
  }
}
