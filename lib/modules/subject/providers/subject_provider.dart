import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:study_planner/modules/subject/models/subject.dart';
import 'package:study_planner/modules/subject/models/topic.dart';
import 'package:study_planner/modules/subject/repositories/subject_repository.dart';
import 'package:study_planner/modules/subject/repositories/topic_repository.dart';
import 'package:study_planner/core/utils/priority_engine.dart';

class SubjectProvider extends ChangeNotifier {
  final SubjectRepository _subjectRepo = SubjectRepository();
  final TopicRepository _topicRepo = TopicRepository();
  final _uuid = const Uuid();

  List<Subject> _subjects = [];
  List<Topic> _topics = [];

  List<Subject> get subjects => _subjects;
  List<Topic> get topics => _topics;

  void load() {
    _subjects = _subjectRepo.getAll();
    _topics = _topicRepo.getAll();
    notifyListeners();
  }

  // --- Subject CRUD ---

  Future<void> addSubject(String name) async {
    final subject = Subject(id: _uuid.v4(), name: name);
    await _subjectRepo.add(subject);
    load();
  }

  Future<void> updateSubject(Subject subject, String newName) async {
    subject.name = newName;
    await _subjectRepo.update(subject);
    load();
  }

  Future<void> deleteSubject(String id) async {
    await _topicRepo.deleteBySubject(id);
    await _subjectRepo.delete(id);
    load();
  }

  // --- Topic CRUD ---

  List<Topic> topicsForSubject(String subjectId) =>
      _topics.where((t) => t.subjectId == subjectId).toList();

  Future<void> addTopic(String subjectId, String name, int estimatedMinutes) async {
    final topic = Topic(
      id: _uuid.v4(),
      subjectId: subjectId,
      name: name,
      estimatedMinutes: estimatedMinutes,
    );
    await _topicRepo.add(topic);
    load();
  }

  Future<void> updateTopic(Topic topic, {String? name, int? estimatedMinutes}) async {
    if (name != null) topic.name = name;
    if (estimatedMinutes != null) topic.estimatedMinutes = estimatedMinutes;
    await _topicRepo.update(topic);
    load();
  }

  Future<void> deleteTopic(String id) async {
    await _topicRepo.delete(id);
    load();
  }

  Future<void> updateTopicStatus(Topic topic, int newStatus) async {
    topic.status = newStatus;
    await _topicRepo.update(topic);
    load();
  }

  // --- Progress & Priority ---

  double subjectCompletion(String subjectId) {
    final topics = topicsForSubject(subjectId);
    return PriorityEngine.completionRate(topics);
  }

  Map<String, double> get allSubjectCompletionRates {
    final rates = <String, double>{};
    for (final subject in _subjects) {
      rates[subject.id] = subjectCompletion(subject.id);
    }
    return rates;
  }

  int get totalTopics => _topics.length;
  int get completedTopics => _topics.where((t) => t.isCompleted).length;
  int get pendingTopics => _topics.where((t) => !t.isCompleted).length;
  int get inProgressTopics => _topics.where((t) => t.isInProgress).length;

  double get overallCompletion => PriorityEngine.completionRate(_topics);

  List<Topic> get suggestedTopics =>
      PriorityEngine.suggestNextTopics(_topics, allSubjectCompletionRates);

  String subjectName(String subjectId) {
    final subject = _subjectRepo.getById(subjectId);
    return subject?.name ?? 'Unknown';
  }

  // --- Search ---

  List<Subject> searchSubjects(String query) => _subjectRepo.search(query);
  List<Topic> searchTopics(String query) => _topicRepo.search(query);
  List<Topic> filterByStatus(int status) => _topicRepo.filterByStatus(status);
}
