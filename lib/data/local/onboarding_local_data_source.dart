// lib/data/local/onboarding_local_data_source.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/onboarding_model.dart';

class OnboardingLocalDataSource {
  static const _key = 'onboarding_data';

  Future<void> save(OnboardingModel data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toMap()));
  }

  Future<OnboardingModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await clear();
        return null;
      }

      return OnboardingModel.fromMap(decoded);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
