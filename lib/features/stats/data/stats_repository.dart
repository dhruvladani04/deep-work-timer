import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionData {
  final DateTime date;
  final String? task;
  final String? category;
  final int durationMinutes;

  SessionData({
    required this.date,
    this.task,
    this.category,
    required this.durationMinutes,
  });
}

class StatsRepository {
  static const _keySessions = 'deep_work_sessions';

  Future<void> saveSession({
    String? taskName,
    String? category,
    int durationMinutes = 25,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList(_keySessions) ?? [];

    // Store as JSON: {"dt": "...", "task": "...", "cat": "Work", "dur": 25}
    final entry = jsonEncode({
      'dt': DateTime.now().toIso8601String(),
      'task': taskName,
      'cat': category,
      'dur': durationMinutes,
    });

    sessions.add(entry);
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
      DateTime? dt;
      if (session.startsWith('{')) {
        try {
          final map = jsonDecode(session);
          dt = DateTime.parse(map['dt']);
        } catch (_) {}
      } else {
        dt = DateTime.tryParse(session);
      }

      if (dt != null) {
        final date = DateTime(dt.year, dt.month, dt.day);
        if (counts.containsKey(date)) {
          counts[date] = (counts[date] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  // New: Get detailed sessions for AI context
  Future<List<SessionData>> getRecentSessions({int days = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList(_keySessions) ?? [];
    final List<SessionData> result = [];
    final now = DateTime.now();

    final cutoff = days == 0
        ? DateTime(now.year, now.month, now.day)
        : now.subtract(Duration(days: days));

    for (final session in sessions) {
      DateTime? dt;
      String? task;
      String? category;
      int duration = 25; // Default for legacy data

      if (session.startsWith('{')) {
        try {
          final map = jsonDecode(session);
          dt = DateTime.parse(map['dt']);
          task = map['task'];
          category = map['cat'];
          duration = map['dur'] ?? 25;
        } catch (_) {}
      } else {
        dt = DateTime.tryParse(session);
      }

      if (dt != null && dt.isAfter(cutoff)) {
        result.add(
          SessionData(
            date: dt,
            task: task,
            category: category,
            durationMinutes: duration,
          ),
        );
      }
    }
    return result;
  }
}

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository();
});
