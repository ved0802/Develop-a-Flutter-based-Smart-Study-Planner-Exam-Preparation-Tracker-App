import 'package:hive/hive.dart';
import 'package:study_planner/core/constants.dart';
import 'package:study_planner/modules/subject/models/subject.dart';

class SubjectRepository {
  Box<Subject> get _box => Hive.box<Subject>(AppConstants.subjectBox);

  List<Subject> getAll() => _box.values.toList();

  Subject? getById(String id) {
    try {
      return _box.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(Subject subject) => _box.put(subject.id, subject);

  Future<void> update(Subject subject) => subject.save();

  Future<void> delete(String id) async {
    final subject = getById(id);
    if (subject != null) await subject.delete();
  }

  List<Subject> search(String query) {
    final q = query.toLowerCase();
    return _box.values
        .where((s) => s.name.toLowerCase().contains(q))
        .toList();
  }
}
