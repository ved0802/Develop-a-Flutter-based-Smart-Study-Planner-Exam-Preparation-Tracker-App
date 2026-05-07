import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:study_planner/modules/schedule/models/study_session.dart';
import 'package:study_planner/modules/schedule/repositories/schedule_repository.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository _repo = ScheduleRepository();
  final _uuid = const Uuid();

  List<StudySession> _sessions = [];

  List<StudySession> get sessions => _sessions;

  void load() {
    _sessions = _repo.getAll();
    _sessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    notifyListeners();
  }

  List<StudySession> sessionsForDate(DateTime date) {
    return _sessions.where((s) {
      return s.scheduledDate.year == date.year &&
          s.scheduledDate.month == date.month &&
          s.scheduledDate.day == date.day;
    }).toList();
  }

  List<StudySession> sessionsForSubject(String subjectId) =>
      _sessions.where((s) => s.subjectId == subjectId).toList();

  List<StudySession> sessionsForTopic(String topicId) =>
      _sessions.where((s) => s.topicId == topicId).toList();

  List<StudySession> get todaySessions => sessionsForDate(DateTime.now());

  List<StudySession> get upcomingSessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions.where((s) => !s.scheduledDate.isBefore(today)).toList();
  }

  int get totalStudyMinutesToday {
    return todaySessions
        .where((s) => s.isCompleted)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get totalScheduledMinutesToday {
    return todaySessions.fold(0, (sum, s) => sum + s.durationMinutes);
  }

  Future<void> addSession({
    required String subjectId,
    required String topicId,
    required DateTime scheduledDate,
    required int durationMinutes,
  }) async {
    final session = StudySession(
      id: _uuid.v4(),
      subjectId: subjectId,
      topicId: topicId,
      scheduledDate: scheduledDate,
      durationMinutes: durationMinutes,
    );
    await _repo.add(session);
    load();
  }

  Future<void> toggleCompletion(StudySession session) async {
    session.isCompleted = !session.isCompleted;
    await _repo.update(session);
    load();
  }

  Future<void> deleteSession(String id) async {
    await _repo.delete(id);
    load();
  }

  Future<void> deleteBySubject(String subjectId) async {
    await _repo.deleteBySubject(subjectId);
    load();
  }

  Future<void> deleteByTopic(String topicId) async {
    await _repo.deleteByTopic(topicId);
    load();
  }

  // Daily study stats for chart (last 7 days)
  Map<DateTime, int> get weeklyStudyMinutes {
    final now = DateTime.now();
    final result = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayMinutes = sessionsForDate(date)
          .where((s) => s.isCompleted)
          .fold(0, (sum, s) => sum + s.durationMinutes);
      result[date] = dayMinutes;
    }
    return result;
  }
}
