import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../stats/presentation/stats_screen.dart';
import '../../sounds/data/sound_service.dart';
import '../../settings/data/theme_service.dart';
import '../application/timer_notifier.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen for phase completions
    ref.listen(timerProvider, (previous, next) {
      if (previous?.phase != next.phase) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${previous?.phase.displayName} Phase Completed!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colorScheme.secondary,
            showCloseIcon: true,
          ),
        );
      }
    });

    final progress = timerState.timeLeft / timerState.initialDuration;
    final minutes = (timerState.timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (timerState.timeLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Deep Work',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const StatsScreen(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.headphones_rounded),
            onPressed: () => _showSoundSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Animated Phase Label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                timerState.phase.displayName,
                key: ValueKey(timerState.phase),
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.0,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Task Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: IntrinsicWidth(
                child: TextFormField(
                  initialValue: timerState.currentTask,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What are you working on?',
                    hintStyle: GoogleFonts.outfit(
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: notifier.setTask,
                ),
              ),
            ),
            const Spacer(),
            // Circular Timer
            Center(
              child: CircularPercentIndicator(
                radius: 140.0,
                lineWidth: 18.0,
                animation: true,
                animateFromLastPercent: true,
                animationDuration: 1000,
                percent: progress.clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$minutes:$seconds',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      timerState.isRunning ? 'FOCUSING' : 'PAUSED',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.outline,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                backgroundColor: colorScheme.surfaceContainerHighest,
                progressColor: colorScheme.primary,
                circularStrokeCap: CircularStrokeCap.round,
                rotateLinearGradient: true,
                // Add a subtle shadow to the whole ring if possible, or just the container
                // widgetIndicator removed
              ),
            ),
            const Spacer(flex: 2),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlBtn(
                  context,
                  icon: Icons.refresh_rounded,
                  onPressed: notifier.reset,
                  label: 'Reset',
                  isSecondary: true,
                ),
                const SizedBox(width: 32),
                FloatingActionButton.large(
                  onPressed: timerState.isRunning
                      ? notifier.pause
                      : notifier.start,
                  elevation: 6,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: Icon(
                    timerState.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 48,
                  ),
                ),
                const SizedBox(
                  width: 80,
                ), // Balance the Reset button visually or add another button
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
    bool isSecondary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          elevation: 0,
          backgroundColor: isSecondary
              ? colorScheme.surfaceContainerHighest
              : colorScheme.secondaryContainer,
          foregroundColor: isSecondary
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSecondaryContainer,
          heroTag: label, // Unique tag
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showSoundSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soundscapes',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildSoundChip(context, ref, null, 'Off', '🔇'),
                      ...SoundNotifier.presets.map(
                        (preset) => _buildSoundChip(
                          context,
                          ref,
                          preset,
                          preset.name,
                          preset.iconEmoji,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSoundChip(
    BuildContext context,
    WidgetRef ref,
    SoundPreset? preset,
    String label,
    String emoji,
  ) {
    final currentSound = ref.watch(soundProvider);
    final notifier = ref.read(soundProvider.notifier);
    final isSelected = currentSound == preset;
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      avatar: Text(emoji),
      label: Text(label),
      backgroundColor: isSelected ? colorScheme.primaryContainer : null,
      onPressed: () {
        if (preset == null) {
          notifier.stop();
        } else {
          notifier.play(preset);
        }
        Navigator.pop(context); // Close sheet after selection
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentState = ref.watch(timerProvider);
            final currentNotifier = ref.read(timerProvider.notifier);
            return AlertDialog(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              title: Text('Settings', style: GoogleFonts.outfit()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSlider(
                    context,
                    'Focus Duration (min)',
                    currentState.focusDuration,
                    (val) => currentNotifier.setFocusDuration(val.toInt()),
                    1,
                    120,
                  ),
                  const SizedBox(height: 20),
                  _buildSlider(
                    context,
                    'Break Duration (min)',
                    currentState.breakDuration,
                    (val) => currentNotifier.setBreakDuration(val.toInt()),
                    1,
                    30,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Theme',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final currentVariant = ref.watch(themeProvider);
                      return DropdownButtonFormField<AppThemeVariant>(
                        value: currentVariant,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: AppThemeVariant.values.map((variant) {
                          final theme = AppTheme.fromVariant(variant);
                          return DropdownMenuItem(
                            value: variant,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.focusColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.breakColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(theme.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newVariant) {
                          if (newVariant != null) {
                            ref
                                .read(themeProvider.notifier)
                                .setTheme(newVariant);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    int value,
    ValueChanged<double> onChanged,
    double min,
    double max,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value', style: Theme.of(context).textTheme.bodyLarge),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
