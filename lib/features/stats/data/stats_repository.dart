import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsRepository {
  static const _keySessions = 'deep_work_sessions';

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList(_keySessions) ?? [];
    sessions.add(DateTime.now().toIso8601String());
    await prefs.setStringList(_keySessions, sessions);
  }

  Future<Map<DateTime, int>> getDailyCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList(_keySessions) ?? [];

    final Map<DateTime, int> counts = {};
    final now = DateTime.now();
    // Initialize last 7 days with 0
    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      counts[date] = 0;
    }

    for (final session in sessions) {
      final dt = DateTime.parse(session);
      // Normalize to date only
      final date = DateTime(dt.year, dt.month, dt.day);
      if (counts.containsKey(date)) {
        counts[date] = (counts[date] ?? 0) + 1;
      }
    }

    return counts;
  }
}

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository();
});
