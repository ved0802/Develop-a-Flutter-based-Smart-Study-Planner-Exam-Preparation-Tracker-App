import 'package:hive/hive.dart';
import 'package:study_planner/core/constants.dart';
import 'package:study_planner/modules/subject/models/topic.dart';

class TopicRepository {
  Box<Topic> get _box => Hive.box<Topic>(AppConstants.topicBox);

  List<Topic> getAll() => _box.values.toList();

  List<Topic> getBySubject(String subjectId) =>
      _box.values.where((t) => t.subjectId == subjectId).toList();

  Topic? getById(String id) {
    try {
      return _box.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(Topic topic) => _box.put(topic.id, topic);

  Future<void> update(Topic topic) => topic.save();

  Future<void> delete(String id) async {
    final topic = getById(id);
    if (topic != null) await topic.delete();
  }

  Future<void> deleteBySubject(String subjectId) async {
    final topics = getBySubject(subjectId);
    for (final t in topics) {
      await t.delete();
    }
  }

  List<Topic> search(String query) {
    final q = query.toLowerCase();
    return _box.values
        .where((t) => t.name.toLowerCase().contains(q))
        .toList();
  }

  List<Topic> filterByStatus(int status) =>
      _box.values.where((t) => t.status == status).toList();
}
