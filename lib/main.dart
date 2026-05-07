import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:study_planner/core/constants.dart';
import 'package:study_planner/core/theme.dart';
import 'package:study_planner/modules/subject/models/subject.dart';
import 'package:study_planner/modules/subject/models/topic.dart';
import 'package:study_planner/modules/schedule/models/study_session.dart';
import 'package:study_planner/modules/subject/providers/subject_provider.dart';
import 'package:study_planner/modules/schedule/providers/schedule_provider.dart';
import 'package:study_planner/modules/dashboard/screens/dashboard_screen.dart';
import 'package:study_planner/modules/subject/screens/subject_management_screen.dart';
import 'package:study_planner/modules/schedule/screens/study_scheduling_screen.dart';
import 'package:study_planner/modules/progress/screens/study_progress_screen.dart';
import 'package:study_planner/modules/search/screens/search_filter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(TopicAdapter());
  Hive.registerAdapter(StudySessionAdapter());

  // Open boxes
  await Hive.openBox<Subject>(AppConstants.subjectBox);
  await Hive.openBox<Topic>(AppConstants.topicBox);
  await Hive.openBox<StudySession>(AppConstants.sessionBox);

  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubjectProvider()..load()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()..load()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _tabs = [
    {'label': 'Dashboard', 'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard},
    {'label': 'Subjects', 'icon': Icons.menu_book_outlined, 'activeIcon': Icons.menu_book},
    {'label': 'Schedule', 'icon': Icons.calendar_today_outlined, 'activeIcon': Icons.calendar_today},
    {'label': 'Progress', 'icon': Icons.trending_up_outlined, 'activeIcon': Icons.trending_up},
    {'label': 'Search', 'icon': Icons.search_outlined, 'activeIcon': Icons.search},
  ];

  static const _screens = [
    DashboardScreen(),
    SubjectManagementScreen(),
    StudySchedulingScreen(),
    StudyProgressScreen(),
    SearchFilterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tabs[_currentIndex]['label'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t['icon'] as IconData),
          selectedIcon: Icon(t['activeIcon'] as IconData),
          label: t['label'] as String,
        )).toList(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.school, size: 40, color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
      children: [
        const Text('Smart Study Planner & Exam Preparation Tracker'),
        const SizedBox(height: 8),
        const Text('Developer: Vansh'),
        const Text('Built with Flutter & Hive'),
      ],
    );
  }
}
