import 'package:hive/hive.dart';

part 'topic.g.dart';

@HiveType(typeId: 1)
class Topic extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  String name;

  @HiveField(3)
  int estimatedMinutes;

  @HiveField(4)
  int status; // 0 = Not Started, 1 = In Progress, 2 = Completed

  Topic({
    required this.id,
    required this.subjectId,
    required this.name,
    this.estimatedMinutes = 30,
    this.status = 0,
  });

  String get statusLabel {
    switch (status) {
      case 1:
        return 'In Progress';
      case 2:
        return 'Completed';
      default:
        return 'Not Started';
    }
  }

  bool get isCompleted => status == 2;
  bool get isInProgress => status == 1;
  bool get isNotStarted => status == 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'name': name,
        'estimatedMinutes': estimatedMinutes,
        'status': status,
      };
}
