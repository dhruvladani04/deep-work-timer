import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/timer/application/timer_notifier.dart';
import 'features/timer/data/timer_state.dart';
import 'features/timer/presentation/timer_screen.dart';
import 'features/settings/data/theme_service.dart'; // Import ThemeService

import 'features/notifications/data/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const ProviderScope(child: DeepWorkApp()));
}

class DeepWorkApp extends ConsumerWidget {
  const DeepWorkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final themeVariant = ref.watch(themeProvider);
    final currentTheme = AppTheme.fromVariant(themeVariant);

    // Dynamic color based on current phase and selected theme
    final seedColor = timerState.phase == TimerPhase.focus
        ? currentTheme.focusColor
        : currentTheme.breakColor;

    return MaterialApp(
      title: 'Deep Work Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.light,
      ),
      home: const TimerScreen(),
    );
  }
}
