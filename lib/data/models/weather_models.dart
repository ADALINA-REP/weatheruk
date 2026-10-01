class GeocodingResponse {
  final List<GeocodingResult>? results;

  GeocodingResponse({this.results});

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    return GeocodingResponse(
      results: (json['results'] as List?)
          ?.map((e) => GeocodingResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GeocodingResult {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;
  final String? countryCode;

  GeocodingResult({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.countryCode,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }
}

class WeatherResponse {
  final CurrentWeather? current;
  final HourlyWeather hourly;
  final DailyWeather daily;

  WeatherResponse({
    this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      current: json['current'] != null
          ? CurrentWeather.fromJson(json['current'] as Map<String, dynamic>)
          : null,
      hourly: HourlyWeather.fromJson(json['hourly'] as Map<String, dynamic>),
      daily: DailyWeather.fromJson(json['daily'] as Map<String, dynamic>),
    );
  }
}

class CurrentWeather {
  final String time;
  final double temperature;
  final int humidity;
  final double feelsLike;
  final int isDay;
  final int weatherCode;
  final double windSpeed;
  final int? windDirection;
  final double? surfacePressure;
  final double? precipitation;

  CurrentWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.feelsLike,
    required this.isDay,
    required this.weatherCode,
    required this.windSpeed,
    this.windDirection,
    this.surfacePressure,
    this.precipitation,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: json['time'] as String,
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).toInt(),
      feelsLike: (json['apparent_temperature'] as num).toDouble(),
      isDay: (json['is_day'] as num).toInt(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      windDirection: (json['wind_direction_10m'] as num?)?.toInt(),
      surfacePressure: (json['surface_pressure'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
    );
  }
}

class HourlyWeather {
  final List<String> time;
  final List<double?> temperatures;
  final List<int?> precipitationProbability;
  final List<int?> weatherCodes;
  final List<int?>? isDay;
  final List<double?>? visibility;
  final List<double?>? surfacePressure;
  final List<int?>? humidity;
  final List<double?>? precipitation;
  final List<double?>? windSpeeds;
  final List<double?>? uvIndex;

  HourlyWeather({
    required this.time,
    required this.temperatures,
    required this.precipitationProbability,
    required this.weatherCodes,
    this.isDay,
    this.visibility,
    this.surfacePressure,
    this.humidity,
    this.precipitation,
    this.windSpeeds,
    this.uvIndex,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: List<String>.from(json['time']),
      temperatures: (json['temperature_2m'] as List).map((e) => (e as num?)?.toDouble()).toList(),
      precipitationProbability: (json['precipitation_probability'] as List).map((e) => (e as num?)?.toInt()).toList(),
      weatherCodes: (json['weather_code'] as List).map((e) => (e as num?)?.toInt()).toList(),
      isDay: (json['is_day'] as List?)?.map((e) => (e as num?)?.toInt()).toList(),
      visibility: (json['visibility'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
      surfacePressure: (json['surface_pressure'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
      humidity: (json['relative_humidity_2m'] as List?)?.map((e) => (e as num?)?.toInt()).toList(),
      precipitation: (json['precipitation'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
      windSpeeds: (json['wind_speed_10m'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
      uvIndex: (json['uv_index'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
    );
  }
}

class DailyWeather {
  final List<String> time;
  final List<int?> weatherCodes;
  final List<double?> maxTemp;
  final List<double?> minTemp;
  final List<String?>? sunrise;
  final List<String?>? sunset;
  final List<double?>? uvIndexMax;
  final List<int?>? precipitationProbabilityMax;
  final List<double?>? windSpeedMax;
  final List<double?>? apparentTempMax;
  final List<double?>? precipitationSum;

  DailyWeather({
    required this.time,
    required this.weatherCodes,
    required this.maxTemp,
    required this.minTemp,
    this.sunrise,
    this.sunset,
    this.uvIndexMax,
    this.precipitationProbabilityMax,
    this.windSpeedMax,
    this.apparentTempMax,
    this.precipitationSum,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      time: List<String>.from(json['time']),
      weatherCodes: (json['weather_code'] as List).map((e) => (e as num?)?.toInt()).toList(),
      maxTemp: (json['temperature_2m_max'] as List).map((e) => (e as num?)?.toDouble()).toList(),
      minTemp: (json['temperature_2m_min'] as List).map((e) => (e as num?)?.toDouble()).toList(),
      sunrise: (json['sunrise'] as List?)?.map((e) => e as String?).toList(),
      sunset: (json['sunset'] as List?)?.map((e) => e as String?).toList(),
      uvIndexMax: (json['uv_index_max'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
      precipitationProbabilityMax: (json['precipitation_probability_max'] as List?)?.map((e) => (e as num?)?.toInt()).toList(),
      windSpeedMax: (json['wind_speed_10m_max'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
      apparentTempMax: (json['apparent_temperature_max'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
      precipitationSum: (json['precipitation_sum'] as List?)?.map((e) => (e as num?)?.toDouble()).toList(),
    );
  }
}

class AirQualityResponse {
  final CurrentAirQuality current;
  final HourlyAirQuality? hourly;

  AirQualityResponse({required this.current, this.hourly});

  factory AirQualityResponse.fromJson(Map<String, dynamic> json) {
    return AirQualityResponse(
      current: CurrentAirQuality.fromJson(json['current'] as Map<String, dynamic>),
      hourly: json['hourly'] != null
          ? HourlyAirQuality.fromJson(json['hourly'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CurrentAirQuality {
  final String time;
  final int? aqi;
  final int? usAqi;
  final double? pm2_5;
  final double? pm10;
  final double? co;
  final double? no2;
  final double? o3;
  final double? so2;

  CurrentAirQuality({
    required this.time,
    this.aqi,
    this.usAqi,
    this.pm2_5,
    this.pm10,
    this.co,
    this.no2,
    this.o3,
    this.so2,
  });

  factory CurrentAirQuality.fromJson(Map<String, dynamic> json) {
    return CurrentAirQuality(
      time: json['time'] as String,
      aqi: (json['european_aqi'] as num?)?.toInt(),
      usAqi: (json['us_aqi'] as num?)?.toInt(),
      pm2_5: (json['pm2_5'] as num?)?.toDouble(),
      pm10: (json['pm10'] as num?)?.toDouble(),
      co: (json['carbon_monoxide'] as num?)?.toDouble(),
      no2: (json['nitrogen_dioxide'] as num?)?.toDouble(),
      o3: (json['ozone'] as num?)?.toDouble(),
      so2: (json['sulphur_dioxide'] as num?)?.toDouble(),
    );
  }
}

class HourlyAirQuality {
  final List<String> time;
  final List<int?>? aqi;

  HourlyAirQuality({required this.time, this.aqi});

  factory HourlyAirQuality.fromJson(Map<String, dynamic> json) {
    return HourlyAirQuality(
      time: List<String>.from(json['time']),
      aqi: (json['european_aqi'] as List?)?.map((e) => (e as num?)?.toInt()).toList(),
    );
  }
}
