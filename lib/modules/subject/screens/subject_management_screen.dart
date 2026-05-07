import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_planner/core/theme.dart';
import 'package:study_planner/modules/subject/models/subject.dart';
import 'package:study_planner/modules/subject/models/topic.dart';
import 'package:study_planner/modules/subject/providers/subject_provider.dart';
import 'package:study_planner/modules/schedule/providers/schedule_provider.dart';
import 'package:study_planner/widgets/empty_state.dart';

class SubjectManagementScreen extends StatelessWidget {
  const SubjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, provider, _) {
        final subjects = provider.subjects;
        return Scaffold(
          body: subjects.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.menu_book_outlined,
                  title: 'No Subjects Yet',
                  subtitle: 'Add your first subject to start planning',
                  actionLabel: 'Add Subject',
                  onAction: () => _showAddSubjectDialog(context),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) =>
                      _SubjectCard(subject: subjects[index]),
                ),
          floatingActionButton: subjects.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddSubjectDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subject'),
                )
              : null,
        );
      },
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subject Name',
            hintText: 'e.g. Mathematics',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<SubjectProvider>().addSubject(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatefulWidget {
  final Subject subject;
  const _SubjectCard({required this.subject});
  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectProvider>();
    final topics = provider.topicsForSubject(widget.subject.id);
    final completion = provider.subjectCompletion(widget.subject.id);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            widget.subject.name.isNotEmpty ? widget.subject.name[0].toUpperCase() : '?',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.subject.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text('${topics.length} topic${topics.length == 1 ? '' : 's'} • ${(completion * 100).toInt()}% done',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') {
                            _showEditSubjectDialog(context, widget.subject);
                          } else if (v == 'delete') {
                            _confirmDelete(context, widget.subject);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completion, minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(completion == 1.0 ? AppTheme.completedColor : colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            if (topics.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: Text('No topics yet. Add one!', style: TextStyle(color: colorScheme.onSurfaceVariant)))
            else
              ...topics.map((t) => _TopicTile(topic: t)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: OutlinedButton.icon(
                onPressed: () => _showAddTopicDialog(context, widget.subject.id),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Topic'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditSubjectDialog(BuildContext context, Subject subject) {
    final controller = TextEditingController(text: subject.name);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Edit Subject'),
      content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Subject Name'), autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () { final n = controller.text.trim(); if (n.isNotEmpty) { context.read<SubjectProvider>().updateSubject(subject, n); Navigator.pop(ctx); } }, child: const Text('Save')),
      ],
    ));
  }

  void _confirmDelete(BuildContext context, Subject subject) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Subject?'),
      content: Text('This will delete "${subject.name}" and all its topics.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () { context.read<ScheduleProvider>().deleteBySubject(subject.id); context.read<SubjectProvider>().deleteSubject(subject.id); Navigator.pop(ctx); },
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    ));
  }

  void _showAddTopicDialog(BuildContext context, String subjectId) {
    final nameCtrl = TextEditingController();
    final minutesCtrl = TextEditingController(text: '30');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('New Topic'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Topic Name', hintText: 'e.g. Calculus Basics'), autofocus: true, textCapitalization: TextCapitalization.sentences),
        const SizedBox(height: 12),
        TextField(controller: minutesCtrl, decoration: const InputDecoration(labelText: 'Estimated Study Time (minutes)', suffixText: 'min'), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () { final n = nameCtrl.text.trim(); final m = int.tryParse(minutesCtrl.text.trim()) ?? 30; if (n.isNotEmpty && m > 0) { context.read<SubjectProvider>().addTopic(subjectId, n, m); Navigator.pop(ctx); } }, child: const Text('Add')),
      ],
    ));
  }
}

class _TopicTile extends StatelessWidget {
  final Topic topic;
  const _TopicTile({required this.topic});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: IconButton(
        icon: Icon(AppTheme.statusIcon(topic.status), color: AppTheme.statusColor(topic.status)),
        onPressed: () { context.read<SubjectProvider>().updateTopicStatus(topic, (topic.status + 1) % 3); },
        tooltip: 'Cycle status: ${topic.statusLabel}',
      ),
      title: Text(topic.name, style: TextStyle(decoration: topic.isCompleted ? TextDecoration.lineThrough : null, color: topic.isCompleted ? colorScheme.onSurfaceVariant : null)),
      subtitle: Text('${topic.estimatedMinutes} min • ${topic.statusLabel}', style: TextStyle(color: AppTheme.statusColor(topic.status), fontSize: 12)),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'edit') {
            _showEditTopicDialog(context, topic);
          } else if (v == 'delete') {
            context.read<ScheduleProvider>().deleteByTopic(topic.id);
            context.read<SubjectProvider>().deleteTopic(topic.id);
          }
        },
        itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete'))],
      ),
    );
  }

  void _showEditTopicDialog(BuildContext context, Topic topic) {
    final nameCtrl = TextEditingController(text: topic.name);
    final minutesCtrl = TextEditingController(text: topic.estimatedMinutes.toString());
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Edit Topic'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Topic Name')),
        const SizedBox(height: 12),
        TextField(controller: minutesCtrl, decoration: const InputDecoration(labelText: 'Estimated Minutes', suffixText: 'min'), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () { final n = nameCtrl.text.trim(); final m = int.tryParse(minutesCtrl.text.trim()); if (n.isNotEmpty) { context.read<SubjectProvider>().updateTopic(topic, name: n, estimatedMinutes: m); Navigator.pop(ctx); } }, child: const Text('Save')),
      ],
    ));
  }
}
