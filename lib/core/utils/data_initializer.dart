import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_planner/modules/subject/providers/subject_provider.dart';
import 'package:study_planner/modules/schedule/providers/schedule_provider.dart';

class DataInitializer {
  static Future<void> initialize(BuildContext context) async {
    final subjProv = context.read<SubjectProvider>();
    final schedProv = context.read<ScheduleProvider>();

    if (subjProv.subjects.isNotEmpty) return;

    // Add Mathematics
    await subjProv.addSubject('Mathematics');
    final math = subjProv.subjects.firstWhere((s) => s.name == 'Mathematics');
    await subjProv.addTopic(math.id, 'Calculus Basics', 45);
    await subjProv.addTopic(math.id, 'Linear Algebra', 60);
    await subjProv.addTopic(math.id, 'Probability', 30);

    // Add Physics
    await subjProv.addSubject('Physics');
    final physics = subjProv.subjects.firstWhere((s) => s.name == 'Physics');
    await subjProv.addTopic(physics.id, 'Quantum Mechanics', 90);
    await subjProv.addTopic(physics.id, 'Thermodynamics', 45);

    // Set some progress
    final topics = subjProv.topics;
    await subjProv.updateTopicStatus(topics[0], 2); // Calculus Completed
    await subjProv.updateTopicStatus(topics[1], 1); // Algebra In Progress

    // Schedule a session for today
    await schedProv.addSession(
      subjectId: math.id,
      topicId: topics[1].id,
      scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      durationMinutes: 60,
    );
  }
}
