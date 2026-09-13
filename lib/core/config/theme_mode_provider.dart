import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_prefs_provider.dart';

const _kThemeModeKey = 'theme_mode';

/// App theme mode, persisted to SharedPreferences. Dark-first: defaults to
/// [ThemeMode.dark] when nothing is stored.
final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    return ThemeModeController(ref.watch(sharedPreferencesProvider));
  },
);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    switch (prefs.getString(_kThemeModeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.dark; // dark-first default
    }
  }

  bool get isLight => state == ThemeMode.light;

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await _prefs.setString(
      _kThemeModeKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  Future<void> setLight(bool light) =>
      setMode(light ? ThemeMode.light : ThemeMode.dark);
}
