import 'package:flutter/foundation.dart';

enum TimerPhase {
  focus,
  breakPhase;

  String get displayName =>
      this == TimerPhase.focus ? 'Deep Focus' : 'Short Break';
}

@immutable
class TimerState {
  final int timeLeft; // in seconds
  final TimerPhase phase;
  final bool isRunning;
  final int initialDuration;
  final int focusDuration; // in minutes
  final int breakDuration; // in minutes
  final String? currentTask;

  const TimerState({
    required this.timeLeft,
    required this.phase,
    required this.isRunning,
    required this.initialDuration,
    required this.focusDuration,
    required this.breakDuration,
    this.currentTask,
  });

  factory TimerState.initial() {
    return const TimerState(
      timeLeft: 25 * 60,
      phase: TimerPhase.focus,
      isRunning: false,
      initialDuration: 25 * 60,
      focusDuration: 25,
      breakDuration: 5,
      currentTask: null,
    );
  }

  TimerState copyWith({
    int? timeLeft,
    TimerPhase? phase,
    bool? isRunning,
    int? initialDuration,
    int? focusDuration,
    int? breakDuration,
    String? currentTask,
  }) {
    return TimerState(
      timeLeft: timeLeft ?? this.timeLeft,
      phase: phase ?? this.phase,
      isRunning: isRunning ?? this.isRunning,
      initialDuration: initialDuration ?? this.initialDuration,
      focusDuration: focusDuration ?? this.focusDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      currentTask: currentTask ?? this.currentTask,
    );
  }
}
