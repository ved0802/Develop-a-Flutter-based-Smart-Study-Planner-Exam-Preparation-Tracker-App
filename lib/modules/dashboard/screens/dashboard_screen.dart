import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:study_planner/core/theme.dart';
import 'package:study_planner/modules/subject/providers/subject_provider.dart';
import 'package:study_planner/modules/schedule/providers/schedule_provider.dart';
import 'package:study_planner/widgets/stat_card.dart';
import 'package:study_planner/widgets/empty_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubjectProvider, ScheduleProvider>(
      builder: (context, subjProv, schedProv, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final hasData = subjProv.subjects.isNotEmpty;

        if (!hasData) {
          return const Scaffold(
            body: EmptyStateWidget(
              icon: Icons.dashboard_outlined,
              title: 'Welcome to StudyMate',
              subtitle: 'Start by adding subjects and topics in the Subjects tab',
            ),
          );
        }

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Greeting
              _buildGreeting(context, subjProv),
              const SizedBox(height: 20),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.5,
                children: [
                  StatCard(icon: Icons.menu_book, label: 'Total Subjects', value: '${subjProv.subjects.length}', iconColor: colorScheme.primary),
                  StatCard(icon: Icons.check_circle, label: 'Completed', value: '${subjProv.completedTopics}', iconColor: AppTheme.completedColor),
                  StatCard(icon: Icons.pending, label: 'Pending', value: '${subjProv.pendingTopics}', iconColor: AppTheme.inProgressColor),
                  StatCard(icon: Icons.timer, label: "Today's Study", value: '${schedProv.totalStudyMinutesToday}m', iconColor: colorScheme.tertiary),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly chart
              Text('📈 Weekly Study Activity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildWeeklyChart(context, schedProv, colorScheme),
              const SizedBox(height: 24),

              // Today's sessions
              Text("📅 Today's Sessions", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTodaySessions(context, schedProv, subjProv, colorScheme),
              const SizedBox(height: 24),

              // Subject completion bars
              Text('📚 Subject Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...subjProv.subjects.map((s) {
                final comp = subjProv.subjectCompletion(s.id);
                final topics = subjProv.topicsForSubject(s.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 100, child: Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: comp, minHeight: 10,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(comp == 1.0 ? AppTheme.completedColor : colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${topics.where((t) => t.isCompleted).length}/${topics.length}', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGreeting(BuildContext context, SubjectProvider provider) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    if (hour < 12) {
      greeting = 'Good Morning';
      icon = Icons.wb_sunny_outlined;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.wb_cloudy_outlined;
    } else {
      greeting = 'Good Evening';
      icon = Icons.nights_stay_outlined;
    }
    final colorScheme = Theme.of(context).colorScheme;
    final overall = provider.overallCompletion;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                  Text('${(overall * 100).toInt()}% overall progress • Keep going!', style: TextStyle(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, ScheduleProvider provider, ColorScheme colorScheme) {
    final data = provider.weeklyStudyMinutes;
    final maxVal = data.values.fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxVal > 0 ? maxVal.toDouble() : 60) * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem('${rod.toY.toInt()} min', TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold));
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date = data.keys.elementAt(value.toInt());
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(DateFormat('E').format(date), style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                    );
                  },
                )),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: data.entries.toList().asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.value.toDouble(),
                      color: colorScheme.primary,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySessions(BuildContext context, ScheduleProvider schedProv, SubjectProvider subjProv, ColorScheme colorScheme) {
    final today = schedProv.todaySessions;
    if (today.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text('No sessions scheduled for today', style: TextStyle(color: colorScheme.onSurfaceVariant))),
        ),
      );
    }
    return Column(
      children: today.map((session) {
        final topic = subjProv.topics.where((t) => t.id == session.topicId).firstOrNull;
        final subject = subjProv.subjects.where((s) => s.id == session.subjectId).firstOrNull;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              session.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: session.isCompleted ? AppTheme.completedColor : colorScheme.onSurfaceVariant,
            ),
            title: Text(topic?.name ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w500, decoration: session.isCompleted ? TextDecoration.lineThrough : null)),
            subtitle: Text('${subject?.name ?? ''} • ${session.durationMinutes} min • ${DateFormat('h:mm a').format(session.scheduledDate)}', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
            trailing: TextButton(
              onPressed: () => schedProv.toggleCompletion(session),
              child: Text(session.isCompleted ? 'Undo' : 'Done'),
            ),
          ),
        );
      }).toList(),
    );
  }
}
