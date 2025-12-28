class TimerCommand {
  final int durationMinutes;
  final bool isBreak;
  final String? taskName;

  TimerCommand({
    required this.durationMinutes,
    required this.isBreak,
    this.taskName,
  });

  @override
  String toString() =>
      'Time: $durationMinutes, Break: $isBreak, Task: $taskName';
}

class SmartParser {
  static TimerCommand parse(String input) {
    final lowerInput = input.toLowerCase();

    // 1. Detect Duration
    int minutes = 25; // Default

    // Regex for hours: "1.5 hours", "2h", "1 hour"
    final hourRegex = RegExp(r'(\d+(\.\d+)?)\s*(h|hour|hours)');
    // Regex for minutes: "45 mins", "30m", "10 minutes"
    final minRegex = RegExp(r'(\d+)\s*(m|min|mins|minutes)');

    final hourMatch = hourRegex.firstMatch(lowerInput);
    final minMatch = minRegex.firstMatch(lowerInput);

    if (hourMatch != null) {
      final val = double.tryParse(hourMatch.group(1) ?? '0') ?? 0;
      minutes = (val * 60).round();
    } else if (minMatch != null) {
      minutes = int.tryParse(minMatch.group(1) ?? '25') ?? 25;
    }

    // 2. Detect Intent (Break vs Focus)
    final isBreak =
        lowerInput.contains('break') ||
        lowerInput.contains('rest') ||
        lowerInput.contains('short');

    // 3. Extract Task Name
    // Remove time components and common prepositions to find the "meat" of the task
    String task = input;

    // Remove time substrings
    if (hourMatch != null) task = task.replaceAll(hourMatch.group(0)!, '');
    if (minMatch != null) task = task.replaceAll(minMatch.group(0)!, '');

    // Remove intent keywords
    task = task.replaceAll(
      RegExp(r'\b(focus|work|deep|break|rest|short)\b', caseSensitive: false),
      '',
    );

    // Remove prepositions often used before time/task
    task = task.replaceAll(RegExp(r'\b(for|on)\b', caseSensitive: false), '');

    // Clean up whitespace
    task = task.replaceAll(RegExp(r'\s+'), ' ').trim();

    return TimerCommand(
      durationMinutes: minutes > 0
          ? minutes
          : 25, // Fallback to 25 if parsing failed/zero
      isBreak: isBreak,
      taskName: task.isNotEmpty ? task : null,
    );
  }
}
