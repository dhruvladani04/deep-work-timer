import 'package:deep_work_timer/features/timer/application/timer_notifier.dart';
import 'package:deep_work_timer/features/timer/data/timer_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state has default durations', () {
    final state = container.read(timerProvider);
    expect(state.phase, TimerPhase.focus);
    expect(state.timeLeft, 25 * 60);
    expect(state.focusDuration, 25);
    expect(state.breakDuration, 5);
    expect(state.currentTask, null);
  });

  test('Setting Task updates state', () {
    final notifier = container.read(timerProvider.notifier);
    notifier.setTask('Study Physics');

    final state = container.read(timerProvider);
    expect(state.currentTask, 'Study Physics');
  });

  test(
    'Setting Focus Duration updates state and resets if in focus not running',
    () {
      final notifier = container.read(timerProvider.notifier);

      // Change focus to 30 mins
      notifier.setFocusDuration(30);

      final state = container.read(timerProvider);
      expect(state.focusDuration, 30);
      expect(
        state.timeLeft,
        30 * 60,
      ); // Should reset immediately as we are in initial focus state
    },
  );

  test('Setting Break Duration updates state', () {
    final notifier = container.read(timerProvider.notifier);

    // Change break to 10 mins
    notifier.setBreakDuration(10);

    final state = container.read(timerProvider);
    expect(state.breakDuration, 10);
    // Should NOT change timeLeft because we are in Focus phase currently
    expect(state.timeLeft, 25 * 60);
  });

  test('Reset uses current preferred durations', () {
    final notifier = container.read(timerProvider.notifier);
    notifier.setFocusDuration(45);
    notifier.start();
    notifier.reset();

    final state = container.read(timerProvider);
    expect(state.timeLeft, 45 * 60);
    expect(state.focusDuration, 45);
  });
}
