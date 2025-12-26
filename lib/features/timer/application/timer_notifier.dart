import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/timer_state.dart';
import '../../stats/data/stats_repository.dart';
import '../../notifications/data/notification_service.dart';

class TimerNotifier extends Notifier<TimerState> {
  Timer? _timer;

  @override
  TimerState build() {
    return TimerState.initial();
  }

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    final newDuration = state.phase == TimerPhase.focus
        ? state.focusDuration * 60
        : state.breakDuration * 60;

    state = state.copyWith(
      timeLeft: newDuration,
      initialDuration: newDuration,
      isRunning: false,
    );
  }

  void setFocusDuration(int minutes) {
    state = state.copyWith(focusDuration: minutes);
    if (!state.isRunning && state.phase == TimerPhase.focus) {
      reset(); // Update current timer if getting ready for focus
    }
  }

  void setBreakDuration(int minutes) {
    state = state.copyWith(breakDuration: minutes);
    if (!state.isRunning && state.phase == TimerPhase.breakPhase) {
      reset(); // Update current timer if getting ready for break
    }
  }

  void setTask(String task) {
    state = state.copyWith(currentTask: task);
  }

  void _tick() {
    if (state.timeLeft > 0) {
      state = state.copyWith(timeLeft: state.timeLeft - 1);
    } else {
      _switchPhase();
    }
  }

  void _switchPhase() {
    _timer?.cancel();
    final nextPhase = state.phase == TimerPhase.focus
        ? TimerPhase.breakPhase
        : TimerPhase.focus;

    // If we just finished a FOCUS session (moving to break), save stats
    if (nextPhase == TimerPhase.breakPhase) {
      // Save Stats
      ref.read(statsRepositoryProvider).saveSession();
      // Notify
      ref
          .read(notificationServiceProvider)
          .showNotification(
            'Focus Session Complete!',
            'Great job! Take a short break.',
          );
    } else {
      // Finished Break, moving to Focus
      ref
          .read(notificationServiceProvider)
          .showNotification('Break Over!', 'Time to get back to deep work.');
    }

    final nextDurationMinutes = nextPhase == TimerPhase.focus
        ? state.focusDuration
        : state.breakDuration;

    final nextDuration = nextDurationMinutes * 60;

    state = state.copyWith(
      phase: nextPhase,
      timeLeft: nextDuration,
      initialDuration: nextDuration,
      isRunning: false,
    );
  }

  @override
  bool updateShouldNotify(TimerState previous, TimerState next) {
    return previous != next;
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});
