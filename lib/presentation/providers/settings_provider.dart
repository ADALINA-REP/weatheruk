import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TemperatureUnit { celsius, fahrenheit }

class SettingsState {
  final TemperatureUnit unit;
  final String pressureUnit;
  final bool hapticsEnabled;
  final String language;
  final String languageCode;
  final bool isDarkMode;

  SettingsState({
    this.unit = TemperatureUnit.celsius,
    this.pressureUnit = 'mb',
    this.hapticsEnabled = true,
    this.language = 'English',
    this.languageCode = 'en',
    this.isDarkMode = true,
  });

  SettingsState copyWith({
    TemperatureUnit? unit,
    String? pressureUnit,
    bool? hapticsEnabled,
    String? language,
    String? languageCode,
    bool? isDarkMode,
  }) {
    return SettingsState(
      unit: unit ?? this.unit,
      pressureUnit: pressureUnit ?? this.pressureUnit,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      language: language ?? this.language,
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? savedLangCode = prefs.getString('language_code');
    String? savedLangName = prefs.getString('language');
    
    if (savedLangCode == null) {
      final systemLoc = ui.PlatformDispatcher.instance.locale.languageCode;
      final supported = {
        'en': 'English',
        'fr': 'Français',
        'ar': 'العربية',
        'es': 'Español',
        'de': 'Deutsch',
        'it': 'Italiano'
      };
      
      if (supported.containsKey(systemLoc)) {
        savedLangCode = systemLoc;
        savedLangName = supported[systemLoc];
      } else {
        savedLangCode = 'en';
        savedLangName = 'English';
      }
    }

    state = SettingsState(
      unit: TemperatureUnit.values[prefs.getInt('temp_unit') ?? 0],
      pressureUnit: prefs.getString('pressure_unit') ?? 'mb',
      hapticsEnabled: prefs.getBool('haptics_enabled') ?? true,
      language: savedLangName ?? 'English',
      languageCode: savedLangCode,
      isDarkMode: prefs.getBool('is_dark_mode') ?? true,
    );
  }

  Future<void> toggleUnit() async {
    final newUnit = state.unit == TemperatureUnit.celsius ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;
    state = state.copyWith(unit: newUnit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('temp_unit', newUnit.index);
  }

  Future<void> togglePressureUnit() async {
    final newUnit = state.pressureUnit == 'mb' ? 'hPa' : 'mb';
    state = state.copyWith(pressureUnit: newUnit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pressure_unit', newUnit);
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', state.isDarkMode);
  }

  Future<void> setLanguage(String name, String code) async {
    state = state.copyWith(language: name, languageCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', name);
    await prefs.setString('language_code', code);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
