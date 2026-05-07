import 'package:hive/hive.dart';
import 'package:study_planner/core/constants.dart';
import 'package:study_planner/modules/schedule/models/study_session.dart';

class ScheduleRepository {
  Box<StudySession> get _box => Hive.box<StudySession>(AppConstants.sessionBox);

  List<StudySession> getAll() => _box.values.toList();

  List<StudySession> getBySubject(String subjectId) =>
      _box.values.where((s) => s.subjectId == subjectId).toList();

  List<StudySession> getByTopic(String topicId) =>
      _box.values.where((s) => s.topicId == topicId).toList();

  List<StudySession> getByDate(DateTime date) {
    return _box.values.where((s) {
      return s.scheduledDate.year == date.year &&
          s.scheduledDate.month == date.month &&
          s.scheduledDate.day == date.day;
    }).toList();
  }

  List<StudySession> getByDateRange(DateTime start, DateTime end) {
    return _box.values.where((s) {
      return !s.scheduledDate.isBefore(start) && !s.scheduledDate.isAfter(end);
    }).toList();
  }

  StudySession? getById(String id) {
    try {
      return _box.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(StudySession session) => _box.put(session.id, session);

  Future<void> update(StudySession session) => session.save();

  Future<void> delete(String id) async {
    final session = getById(id);
    if (session != null) await session.delete();
  }

  Future<void> deleteBySubject(String subjectId) async {
    final sessions = getBySubject(subjectId);
    for (final s in sessions) {
      await s.delete();
    }
  }

  Future<void> deleteByTopic(String topicId) async {
    final sessions = getByTopic(topicId);
    for (final s in sessions) {
      await s.delete();
    }
  }
}
