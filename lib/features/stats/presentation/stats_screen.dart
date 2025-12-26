import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/stats_repository.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  Map<DateTime, int>? _dailyCounts;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ref.read(statsRepositoryProvider).getDailyCounts();
      if (mounted) {
        setState(() {
          _dailyCounts = stats;
        });
      }
    } catch (e) {
      // Gracefully handle error (e.g. MissingPluginException if hot reloaded)
      // by showing empty stats instead of indefinite loading
      if (mounted) {
        setState(() {
          _dailyCounts = {};
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final todayCount = _dailyCounts?[todayDate] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      height: 500,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Progress',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Today: $todayCount sessions',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: _dailyCounts == null
                ? const Center(child: CircularProgressIndicator())
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          (_dailyCounts!.values.isEmpty
                                  ? 5
                                  : _dailyCounts!.values.reduce(
                                          (a, b) => a > b ? a : b,
                                        ) +
                                        2)
                              .toDouble(),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = _dailyCounts!.keys.elementAt(
                                value.toInt(),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('E').format(date)[0],
                                  style: GoogleFonts.outfit(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _convertStatsToBarGroups(colorScheme),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _convertStatsToBarGroups(ColorScheme colorScheme) {
    if (_dailyCounts == null) return [];
    // Sort keys just in case, though repo returns them sorted (reversed in logic but map insertion order usually preserved if simple)
    // Actually repo makes valid keys. We populated 0-6 days ago. So index 0 is today, index 6 is 7 days ago.
    // Let's reverse for chart: Left (oldest) -> Right (newest)

    final sortedKeys = _dailyCounts!.keys.toList()..sort();

    return List.generate(sortedKeys.length, (index) {
      final date = sortedKeys[index];
      final count = _dailyCounts![date] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: count > 0
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            width: 16,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 0, // No background height fixed, or maybe set a max?
              // Let's just keep simple bars
            ),
          ),
        ],
      );
    });
  }
}
