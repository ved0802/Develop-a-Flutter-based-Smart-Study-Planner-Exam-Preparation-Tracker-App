import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:study_planner/modules/subject/models/subject.dart';
import 'package:study_planner/modules/subject/models/topic.dart';
import 'package:study_planner/modules/subject/providers/subject_provider.dart';
import 'package:study_planner/modules/schedule/providers/schedule_provider.dart';
import 'package:study_planner/modules/schedule/models/study_session.dart';
import 'package:study_planner/widgets/empty_state.dart';

class StudySchedulingScreen extends StatelessWidget {
  const StudySchedulingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScheduleProvider, SubjectProvider>(
      builder: (context, schedProv, subjProv, _) {
        final sessions = schedProv.upcomingSessions;
        return Scaffold(
          body: sessions.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.calendar_today_outlined,
                  title: 'No Sessions Scheduled',
                  subtitle: 'Plan your study sessions to stay on track',
                  actionLabel: 'Schedule Session',
                  onAction: () => _showAddSessionDialog(context),
                )
              : _buildSessionList(context, sessions, subjProv, schedProv),
          floatingActionButton: sessions.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddSessionDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Schedule'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSessionList(BuildContext context, List<StudySession> sessions, SubjectProvider subjProv, ScheduleProvider schedProv) {
    // Group by date
    final grouped = <String, List<StudySession>>{};
    for (final s in sessions) {
      final key = DateFormat('EEEE, MMM d').format(s.scheduledDate);
      grouped.putIfAbsent(key, () => []).add(s);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateLabel = grouped.keys.elementAt(index);
        final daySessions = grouped[dateLabel]!;
        final colorScheme = Theme.of(context).colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(dateLabel, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ...daySessions.map((session) {
              final subject = subjProv.subjects.where((s) => s.id == session.subjectId).firstOrNull;
              final topic = subjProv.topics.where((t) => t.id == session.topicId).firstOrNull;
              return Dismissible(
                key: Key(session.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => schedProv.deleteSession(session.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: colorScheme.error, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.delete, color: colorScheme.onError),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: session.isCompleted,
                      onChanged: (_) => schedProv.toggleCompletion(session),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    title: Text(
                      topic?.name ?? 'Unknown Topic',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: session.isCompleted ? TextDecoration.lineThrough : null,
                        color: session.isCompleted ? colorScheme.onSurfaceVariant : null,
                      ),
                    ),
                    subtitle: Text(
                      '${subject?.name ?? 'Unknown'} • ${session.durationMinutes} min • ${DateFormat('h:mm a').format(session.scheduledDate)}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: Icon(Icons.drag_handle, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showAddSessionDialog(BuildContext context) {
    final subjProv = context.read<SubjectProvider>();
    if (subjProv.subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add subjects and topics first!')));
      return;
    }

    Subject? selectedSubject;
    Topic? selectedTopic;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final durationCtrl = TextEditingController(text: '30');
    List<Topic> availableTopics = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Schedule Study Session'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Subject dropdown
              DropdownButtonFormField<Subject>(
                decoration: const InputDecoration(labelText: 'Subject'),
                items: subjProv.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (s) {
                  setState(() {
                    selectedSubject = s;
                    selectedTopic = null;
                    availableTopics = s != null ? subjProv.topicsForSubject(s.id) : [];
                  });
                },
              ),
              const SizedBox(height: 12),
              // Topic dropdown
              DropdownButtonFormField<Topic>(
                decoration: const InputDecoration(labelText: 'Topic'),
                items: availableTopics.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                onChanged: (t) => setState(() => selectedTopic = t),
                initialValue: selectedTopic,
              ),
              const SizedBox(height: 12),
              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('EEE, MMM d, yyyy').format(selectedDate)),
                onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (d != null) setState(() => selectedDate = d);
                },
              ),
              // Time picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: Text(selectedTime.format(ctx)),
                onTap: () async {
                  final t = await showTimePicker(context: ctx, initialTime: selectedTime);
                  if (t != null) setState(() => selectedTime = t);
                },
              ),
              const SizedBox(height: 8),
              TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Duration (minutes)', suffixText: 'min'), keyboardType: TextInputType.number),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (selectedSubject == null || selectedTopic == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select subject and topic')));
                  return;
                }
                final dur = int.tryParse(durationCtrl.text.trim()) ?? 30;
                final dateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                
                if (dateTime.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot schedule sessions in the past!')),
                  );
                  return;
                }

                context.read<ScheduleProvider>().addSession(
                  subjectId: selectedSubject!.id,
                  topicId: selectedTopic!.id,
                  scheduledDate: dateTime,
                  durationMinutes: dur,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
