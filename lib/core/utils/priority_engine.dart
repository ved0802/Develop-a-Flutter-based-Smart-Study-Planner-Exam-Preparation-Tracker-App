import 'package:study_planner/modules/subject/models/topic.dart';

/// Priority engine that suggests which topics to study next.
class PriorityEngine {
  /// Returns topics sorted by priority (lowest completion subjects first,
  /// then not-started topics before in-progress ones).
  static List<Topic> suggestNextTopics(
    List<Topic> allTopics,
    Map<String, double> subjectCompletionRates,
  ) {
    // Filter only incomplete topics
    final incomplete = allTopics.where((t) => !t.isCompleted).toList();

    // Sort: subjects with lowest completion first, then not-started before in-progress
    incomplete.sort((a, b) {
      final aRate = subjectCompletionRates[a.subjectId] ?? 0.0;
      final bRate = subjectCompletionRates[b.subjectId] ?? 0.0;

      // Primary: lower completion rate first
      if ((aRate - bRate).abs() > 0.01) {
        return aRate.compareTo(bRate);
      }

      // Secondary: not-started (0) before in-progress (1)
      return a.status.compareTo(b.status);
    });

    return incomplete;
  }

  /// Calculate completion percentage for a set of topics belonging to a subject.
  static double completionRate(List<Topic> topics) {
    if (topics.isEmpty) return 0.0;
    final completed = topics.where((t) => t.isCompleted).length;
    return completed / topics.length;
  }

  /// Get subjects sorted by completion rate (ascending = most needing attention first).
  static List<MapEntry<String, double>> subjectsByPriority(
    Map<String, List<Topic>> topicsBySubject,
  ) {
    final rates = <String, double>{};
    for (final entry in topicsBySubject.entries) {
      rates[entry.key] = completionRate(entry.value);
    }
    final sorted = rates.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted;
  }
}
