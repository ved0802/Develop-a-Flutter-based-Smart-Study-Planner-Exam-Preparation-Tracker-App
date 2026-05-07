import 'package:flutter_test/flutter_test.dart';
import 'package:study_planner/core/utils/priority_engine.dart';
import 'package:study_planner/modules/subject/models/topic.dart';

void main() {
  group('PriorityEngine', () {
    test('completionRate returns 0 for empty list', () {
      expect(PriorityEngine.completionRate([]), 0.0);
    });

    test('completionRate returns correct value', () {
      final topics = [
        Topic(id: '1', subjectId: 's1', name: 'T1', status: 2),
        Topic(id: '2', subjectId: 's1', name: 'T2', status: 0),
        Topic(id: '3', subjectId: 's1', name: 'T3', status: 1),
        Topic(id: '4', subjectId: 's1', name: 'T4', status: 2),
      ];
      expect(PriorityEngine.completionRate(topics), 0.5);
    });

    test('completionRate returns 1.0 when all completed', () {
      final topics = [
        Topic(id: '1', subjectId: 's1', name: 'T1', status: 2),
        Topic(id: '2', subjectId: 's1', name: 'T2', status: 2),
      ];
      expect(PriorityEngine.completionRate(topics), 1.0);
    });

    test('suggestNextTopics prioritizes lower completion subjects', () {
      final topics = [
        Topic(id: '1', subjectId: 's1', name: 'Math T1', status: 0),
        Topic(id: '2', subjectId: 's1', name: 'Math T2', status: 2),
        Topic(id: '3', subjectId: 's2', name: 'Phys T1', status: 0),
        Topic(id: '4', subjectId: 's2', name: 'Phys T2', status: 0),
      ];
      final rates = {'s1': 0.5, 's2': 0.0};
      final result = PriorityEngine.suggestNextTopics(topics, rates);

      // Physics topics should come first (0% completion)
      expect(result.first.subjectId, 's2');
    });

    test('suggestNextTopics excludes completed', () {
      final topics = [
        Topic(id: '1', subjectId: 's1', name: 'T1', status: 2),
        Topic(id: '2', subjectId: 's1', name: 'T2', status: 0),
      ];
      final result = PriorityEngine.suggestNextTopics(topics, {'s1': 0.5});
      expect(result.length, 1);
      expect(result.first.id, '2');
    });

    test('Topic status labels are correct', () {
      expect(Topic(id: '1', subjectId: 's', name: 'T', status: 0).statusLabel, 'Not Started');
      expect(Topic(id: '2', subjectId: 's', name: 'T', status: 1).statusLabel, 'In Progress');
      expect(Topic(id: '3', subjectId: 's', name: 'T', status: 2).statusLabel, 'Completed');
    });
  });
}
