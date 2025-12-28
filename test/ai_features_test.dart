import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deep_work_timer/features/ai/data/smart_parser.dart';
import 'package:deep_work_timer/features/stats/data/stats_repository.dart';
import 'package:deep_work_timer/features/timer/application/timer_notifier.dart';
import 'package:deep_work_timer/features/ai/data/api_key_service.dart';
import 'package:deep_work_timer/features/ai/data/ai_coach_service.dart';

// 1. Create a Mock AI Service
class MockAICoachService extends AICoachService {
  @override
  Future<String> categorizeTask({
    required String apiKey,
    required String task,
  }) async {
    if (task.contains('Code')) return 'Work';
    if (task.contains('Run')) return 'Health';
    return 'Other';
  }
}

// 2. Mock Notifier for API Key
class MockApiKeyService extends ApiKeyService {
  @override
  String? build() {
    return 'dummy_key'; // Simulate existing key
  }
}

void main() {
  group('AI Feature Integration Tests', () {
    // Feature 1: Smart NLP Timer Input
    test('SmartParser parses "Focus for 45m on Coding" correctly', () {
      final result = SmartParser.parse('Focus for 45m on Coding');

      expect(result.durationMinutes, 45);
      expect(result.taskName, 'Coding');
      expect(result.isBreak, false);
    });

    test('SmartParser parses "Take a 10m break" correctly', () {
      final result = SmartParser.parse('Take a 10m break');

      expect(result.durationMinutes, 10);
      expect(result.isBreak, true);
    });

    // Feature 2: Data Persistence (Duration + Category)
    test(
      'StatsRepository saves and retrieves SessionData with Category',
      () async {
        SharedPreferences.setMockInitialValues({});
        final repo = StatsRepository();

        await repo.saveSession(
          taskName: 'AI Integration Test',
          category: 'Testing',
          durationMinutes: 90,
        );

        final sessions = await repo.getRecentSessions(days: 0);
        expect(sessions.first.category, 'Testing');
        expect(sessions.first.durationMinutes, 90);
      },
    );

    // Feature 3: Intelligent Task Categorization (Logic Integration)
    test(
      'TimerNotifier auto-categorizes task when API Key is present',
      () async {
        // Setup Container with Overrides
        final container = ProviderContainer(
          overrides: [
            // Override AI Coach with Mock
            aiCoachProvider.overrideWithValue(MockAICoachService()),
            // Override API Key to simulate logged in state
            apiKeyProvider.overrideWith(() => MockApiKeyService()),
          ],
        );

        final notifier = container.read(timerProvider.notifier);

        // Action: Set a task
        await notifier.setTask('Write Code');

        // Verify: Logic should have called MockAICoachService
        final state = container.read(timerProvider);

        expect(state.currentTask, 'Write Code');
        expect(state.currentCategory, 'Work'); // Mock returns 'Work' for 'Code'
      },
    );

    test('TimerNotifier handles "Other" category', () async {
      final container = ProviderContainer(
        overrides: [
          aiCoachProvider.overrideWithValue(MockAICoachService()),
          apiKeyProvider.overrideWith(() => MockApiKeyService()),
        ],
      );

      final notifier = container.read(timerProvider.notifier);
      await notifier.setTask('Random Task'); // Should map to 'Other'

      final state = container.read(timerProvider);
      expect(state.currentCategory, 'Other');
    });
  });
}
