import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 2)
class StudySession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String topicId;

  @HiveField(3)
  DateTime scheduledDate;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  bool isCompleted;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.scheduledDate,
    this.durationMinutes = 30,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'topicId': topicId,
        'scheduledDate': scheduledDate.toIso8601String(),
        'durationMinutes': durationMinutes,
        'isCompleted': isCompleted,
      };
}
