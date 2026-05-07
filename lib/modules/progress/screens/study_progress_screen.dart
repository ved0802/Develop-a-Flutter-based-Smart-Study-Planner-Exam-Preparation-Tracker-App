import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_planner/core/theme.dart';
import 'package:study_planner/modules/subject/providers/subject_provider.dart';
import 'package:study_planner/widgets/empty_state.dart';

class StudyProgressScreen extends StatelessWidget {
  const StudyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, provider, _) {
        final subjects = provider.subjects;
        if (subjects.isEmpty) {
          return const Scaffold(
            body: EmptyStateWidget(
              icon: Icons.trending_up_outlined,
              title: 'No Progress to Track',
              subtitle: 'Add subjects and topics first',
            ),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;
        final suggested = provider.suggestedTopics.take(5).toList();

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overall progress card
              _buildOverallProgressCard(context, provider, colorScheme),
              const SizedBox(height: 20),

              // Suggested topics
              if (suggested.isNotEmpty) ...[
                Text('📌 Suggested Next', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...suggested.map((topic) {
                  final subjectName = provider.subjectName(topic.subjectId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.statusColor(topic.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.lightbulb_outline, color: AppTheme.statusColor(topic.status)),
                      ),
                      title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('$subjectName • ${topic.estimatedMinutes} min • ${topic.statusLabel}', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                      trailing: _StatusChip(status: topic.status, onTap: () {
                        provider.updateTopicStatus(topic, (topic.status + 1) % 3);
                      }),
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // Per-subject progress
              Text('📊 Subject Progress', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...subjects.map((subject) {
                final topics = provider.topicsForSubject(subject.id);
                final completion = provider.subjectCompletion(subject.id);
                final completed = topics.where((t) => t.isCompleted).length;
                final inProg = topics.where((t) => t.isInProgress).length;
                final notStarted = topics.where((t) => t.isNotStarted).length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(subject.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
                            Text('${(completion * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: completion == 1.0 ? AppTheme.completedColor : colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completion, minHeight: 8,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(completion == 1.0 ? AppTheme.completedColor : colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _MiniStat(label: 'Done', value: '$completed', color: AppTheme.completedColor),
                            const SizedBox(width: 16),
                            _MiniStat(label: 'In Progress', value: '$inProg', color: AppTheme.inProgressColor),
                            const SizedBox(width: 16),
                            _MiniStat(label: 'Not Started', value: '$notStarted', color: AppTheme.notStartedColor),
                          ],
                        ),
                        if (topics.isNotEmpty) ...[
                          const Divider(height: 20),
                          ...topics.map((t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(AppTheme.statusIcon(t.status), size: 16, color: AppTheme.statusColor(t.status)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(t.name, style: TextStyle(fontSize: 13, decoration: t.isCompleted ? TextDecoration.lineThrough : null))),
                                Text(t.statusLabel, style: TextStyle(fontSize: 11, color: AppTheme.statusColor(t.status))),
                              ],
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallProgressCard(BuildContext context, SubjectProvider provider, ColorScheme colorScheme) {
    final overall = provider.overallCompletion;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [colorScheme.primaryContainer.withValues(alpha: 0.6), colorScheme.secondaryContainer.withValues(alpha: 0.4)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80, height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: overall, strokeWidth: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(overall == 1.0 ? AppTheme.completedColor : colorScheme.primary),
                      ),
                      Center(child: Text('${(overall * 100).toInt()}%', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overall Progress', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${provider.completedTopics} of ${provider.totalTopics} topics completed', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('${provider.pendingTopics} pending • ${provider.inProgressTopics} in progress', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text('$value $label', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }
}

class _StatusChip extends StatelessWidget {
  final int status;
  final VoidCallback onTap;
  const _StatusChip({required this.status, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final labels = ['Start', 'Done', 'Reset'];
    return ActionChip(
      label: Text(labels[status], style: TextStyle(fontSize: 11, color: AppTheme.statusColor((status + 1) % 3))),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
