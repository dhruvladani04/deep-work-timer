import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple model to hold stats for the prompt
class CoachStats {
  final int sessionsToday;
  final int totalMinutesToday;
  final List<String> recentTasks;

  CoachStats({
    required this.sessionsToday,
    required this.totalMinutesToday,
    this.recentTasks = const [],
  });
}

class AICoachService {
  Future<String> getProductivityInsight({
    required String apiKey,
    required CoachStats stats,
  }) async {
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

      final taskSummary = stats.recentTasks.isEmpty
          ? "general tasks"
          : stats.recentTasks.join(', ');

      final prompt =
          '''
Role: You are a high-performance productivity coach.

Data: 
> * Sessions Today: ${stats.sessionsToday}
> * Total Focus: ${stats.totalMinutesToday} mins
> * Recent Tasks: $taskSummary

Task: Provide a brief, high-impact debrief for the user.

Insight: One specific observation connecting their task volume to their focus time. (e.g., "You're tackling complex tasks efficiently").

Flow Tip: One actionable tactic (e.g., Pomodoro, task-batching, or environmental tweak) tailored to their current momentum.

The Push: A punchy, one-sentence quote.

Constraints: 
> * Keep it under 80 words.
> * Use a "Coach-to-Athlete" tone: encouraging, direct, and professional.
> * Use Markdown bolding for key phrases.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ??
          "I couldn't generate an insight right now. Keep going!";
    } catch (e) {
      if (e.toString().contains('API_KEY_INVALID')) {
        throw 'Invalid API Key. Please check your settings.';
      }
      return 'Error connecting to Coach: $e';
    }
  }

  Future<String> categorizeTask({
    required String apiKey,
    required String task,
  }) async {
    try {
      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

      final prompt =
          '''
Classify the task "$task" into exactly one of these categories:
- Work
- Study
- Health
- Chores
- Leisure
- Other

Return ONLY the single word of the category. No punctuation.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? 'Other';
      return text;
    } catch (e) {
      return 'Other';
    }
  }
}

final aiCoachProvider = Provider<AICoachService>((ref) {
  return AICoachService();
});
