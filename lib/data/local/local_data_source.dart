// lib/data/local/local_data_source.dart


import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const.dart';

class LocalDataSource {
  // ── Theme ─────────────────────────────────────
  Future<String?> getSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.kThemeMode);
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kThemeMode, mode);
  }

  // ── Onboarding ────────────────────────────────
  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.kOnboarded) ?? false;
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kOnboarded, true);
  }

  // ── Clear all ────────────────────────────────
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
