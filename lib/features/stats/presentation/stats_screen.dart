import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/stats_repository.dart';
import '../../ai/data/api_key_service.dart';
import '../../ai/data/ai_coach_service.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  Map<DateTime, int> _dailyStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final repo = ref.read(statsRepositoryProvider);
      final stats = await repo.getDailyCounts();
      if (mounted) {
        setState(() {
          _dailyStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _todayCount {
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    return _dailyStats[todayKey] ?? 0;
  }

  // AI Coach Logic
  Future<void> _askCoach() async {
    final apiKey = ref.read(apiKeyProvider);

    if (apiKey == null || apiKey.isEmpty) {
      await _showApiKeyDialog();
      // Re-read after potential save
      final newKey = ref.read(apiKeyProvider);
      if (newKey == null || newKey.isEmpty) return; // User cancelled or empty
      _fetchInsight(newKey);
    } else {
      _fetchInsight(apiKey);
    }
  }

  Future<void> _fetchInsight(String apiKey) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ref.read(statsRepositoryProvider);

      // Get detailed sessions for today
      final allSessions = await repo.getRecentSessions(days: 0); // Today only

      final tasks = allSessions
          .map((e) => e.task)
          .where((t) => t != null && t.isNotEmpty)
          .cast<String>()
          .toSet() // Unique
          .toList();

      // Calculate actual total minutes from sessions
      final minutes = allSessions.fold<int>(
        0,
        (sum, item) => sum + item.durationMinutes,
      );

      final insight = await ref
          .read(aiCoachProvider)
          .getProductivityInsight(
            apiKey: apiKey,
            stats: CoachStats(
              sessionsToday: _todayCount,
              totalMinutesToday: minutes,
              recentTasks: tasks,
            ),
          );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      _showInsightDialog(insight);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Coach Error: $e')));
    }
  }

  Future<void> _showApiKeyDialog() async {
    String inputKey = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Connect AI Coach',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your Google Gemini API Key to unlock personalized insights.',
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Gemini API Key',
                  hintText: 'AIzaSy...',
                ),
                onChanged: (val) => inputKey = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(apiKeyProvider.notifier).setKey(inputKey);
                Navigator.pop(context);
              },
              child: const Text('Save & Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showInsightDialog(String insight) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 32),
          title: Text(
            'Coach Says',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(insight, style: GoogleFonts.outfit(fontSize: 16)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Thanks!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Preparing data for the chart
    final List<BarChartGroupData> barGroups = [];
    final today = DateTime.now();

    // Create bars for last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      final count = _dailyStats[dateKey] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: 6 - i, // 0 to 6
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: i == 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withOpacity(0.5),
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Productivity',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // ✨ Ask Coach Button
              FilledButton.tonal(
                onPressed: _askCoach,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome_rounded),
                    SizedBox(width: 8),
                    Text('Ask Coach'),
                  ],
                ),
              ),
            ],
          ),

          // Debug / Test Data Button
          TextButton(
            onPressed: () async {
              final tasks = [
                'Coding',
                'Writing',
                'Reading',
                'Planning',
                'Design',
              ];
              final randomTask = (tasks..shuffle()).first;
              final randomDuration = [
                25,
                45,
                60,
                90,
              ].first; // Varying durations

              await ref
                  .read(statsRepositoryProvider)
                  .saveSession(
                    taskName: randomTask,
                    durationMinutes: randomDuration,
                  );
              await _loadStats(); // Refresh UI
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added 1 session: $randomTask ($randomDuration min)',
                  ),
                ),
              );
            },
            child: const Text('Add Test Session (+Task & Time)'),
          ),

          const SizedBox(height: 24),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_dailyStats.isEmpty)
            const Expanded(
              child: Center(child: Text('No sessions recorded yet.')),
            )
          else
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final index = val.toInt();
                          if (index < 0 || index > 6) return const SizedBox();
                          final d = today.subtract(Duration(days: 6 - index));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('E').format(d), // Mon, Tue...
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Total',
                      style: GoogleFonts.outfit(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$_todayCount Sessions',
                      style: GoogleFonts.outfit(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
