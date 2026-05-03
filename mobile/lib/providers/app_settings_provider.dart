import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  return AppSettingsNotifier()..load();
});

class AppSettingsState {
  final ThemeMode themeMode;
  final String apiBaseUrl;
  final bool hasCompletedOnboarding;
  final bool largeText;

  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.apiBaseUrl = AppConstants.apiBaseUrl,
    this.hasCompletedOnboarding = false,
    this.largeText = false,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? apiBaseUrl,
    bool? hasCompletedOnboarding,
    bool? largeText,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      largeText: largeText ?? this.largeText,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(const AppSettingsState());

  static const _themeKey = 'neurosign.theme_mode';
  static const _apiUrlKey = 'neurosign.api_base_url';
  static const _onboardingKey = 'neurosign.has_completed_onboarding';
  static const _largeTextKey = 'neurosign.large_text';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? ThemeMode.system.name;
    state = state.copyWith(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == themeName,
        orElse: () => ThemeMode.system,
      ),
      apiBaseUrl: prefs.getString(_apiUrlKey) ?? AppConstants.apiBaseUrl,
      hasCompletedOnboarding: prefs.getBool(_onboardingKey) ?? false,
      largeText: prefs.getBool(_largeTextKey) ?? false,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.name);
  }

  Future<void> setApiBaseUrl(String apiBaseUrl) async {
    final normalized = apiBaseUrl.trim();
    if (normalized.isEmpty) return;
    state = state.copyWith(apiBaseUrl: normalized);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, normalized);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> resetOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
  }

  Future<void> setLargeText(bool value) async {
    state = state.copyWith(largeText: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_largeTextKey, value);
  }
}
