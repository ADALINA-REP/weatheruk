import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weather_models.dart';
import '../../data/api/open_meteo_service.dart';

// Default to London, UK for WeatherUK
final defaultLocation = GeocodingResult(
  id: 2643743,
  name: 'London',
  latitude: 51.5074,
  longitude: -0.1278,
  country: 'United Kingdom',
  countryCode: 'GB',
);

class SelectedLocationNotifier extends Notifier<GeocodingResult> {
  @override
  GeocodingResult build() {
    return defaultLocation;
  }

  void set(GeocodingResult location) {
    state = location;
  }
}

final selectedLocationProvider = NotifierProvider<SelectedLocationNotifier, GeocodingResult>(SelectedLocationNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void set(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final citySearchProvider = FutureProvider.family<GeocodingResponse, String>((ref, query) async {
  if (query.isEmpty) return GeocodingResponse(results: []);
  final apiService = OpenMeteoService();
  return apiService.searchCity(query);
});

class RecentLocationsNotifier extends Notifier<List<GeocodingResult>> {
  @override
  List<GeocodingResult> build() {
    return [];
  }

  void add(GeocodingResult location) {
    if (state.any((l) => l.id == location.id)) {
      state = [location, ...state.where((l) => l.id != location.id)];
    } else {
      state = [location, ...state];
    }
    if (state.length > 5) state = state.sublist(0, 5);
  }

  void remove(int id) {
    state = state.where((l) => l.id != id).toList();
  }
}

final recentLocationsProvider = NotifierProvider<RecentLocationsNotifier, List<GeocodingResult>>(RecentLocationsNotifier.new);
