// lib/view_model/theme_view_model.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/const.dart';

final themeViewModelProvider =
    StateNotifierProvider<ThemeViewModel, ThemeMode>((ref) {
  return ThemeViewModel();
});

class ThemeViewModel extends StateNotifier<ThemeMode> {
  ThemeViewModel() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs  = await SharedPreferences.getInstance();
    final saved  = prefs.getString(AppConstants.kThemeMode);
    if (saved != null && mounted) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == saved, orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kThemeMode, mode.name);
  }

  void toggleDarkLight() =>
      setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  bool get isDark   => state == ThemeMode.dark;
  bool get isLight  => state == ThemeMode.light;
  bool get isSystem => state == ThemeMode.system;
}
