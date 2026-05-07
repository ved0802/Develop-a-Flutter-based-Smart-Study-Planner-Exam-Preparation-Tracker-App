import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_planner/core/theme.dart';

import 'package:intl/intl.dart';
import 'package:study_planner/modules/subject/models/topic.dart';
import 'package:study_planner/modules/subject/providers/subject_provider.dart';
import 'package:study_planner/modules/schedule/providers/schedule_provider.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});
  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchCtrl = TextEditingController();
  String? _filterSubjectId;
  int? _filterStatus;
  DateTime? _filterDate;
  List<Topic> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _performSearch(SubjectProvider provider) {
    final query = _searchCtrl.text.trim();
    List<Topic> results;

    if (query.isNotEmpty) {
      results = provider.searchTopics(query);
    } else {
      results = List.from(provider.topics);
    }

    // Apply filters
    if (_filterSubjectId != null) {
      results = results.where((t) => t.subjectId == _filterSubjectId).toList();
    }
    if (_filterStatus != null) {
      results = results.where((t) => t.status == _filterStatus).toList();
    }

    if (_filterDate != null) {
      final schedProv = context.read<ScheduleProvider>();
      final sessionsOnDate = schedProv.sessionsForDate(_filterDate!);
      final topicIdsOnDate = sessionsOnDate.map((s) => s.topicId).toSet();
      results = results.where((t) => topicIdsOnDate.contains(t.id)).toList();
    }

    setState(() {
      _results = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Search bar + filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search topics...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _performSearch(provider); })
                        : null,
                  ),
                  onChanged: (_) => _performSearch(provider),
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Subject filter
                      _FilterDropdown(
                        label: _filterSubjectId != null
                            ? provider.subjectName(_filterSubjectId!)
                            : 'All Subjects',
                        icon: Icons.menu_book,
                        items: [
                          DropdownMenuItem<String?>(value: null, child: const Text('All Subjects')),
                          ...provider.subjects.map((s) => DropdownMenuItem<String?>(value: s.id, child: Text(s.name))),
                        ],
                        onChanged: (v) { setState(() => _filterSubjectId = v); _performSearch(provider); },
                      ),
                      const SizedBox(width: 8),
                      // Status filter chips
                      _StatusFilterChip(
                        label: 'All',
                        selected: _filterStatus == null,
                        onSelected: () { setState(() => _filterStatus = null); _performSearch(provider); },
                      ),
                      const SizedBox(width: 4),
                      _StatusFilterChip(
                        label: 'Not Started',
                        selected: _filterStatus == 0,
                        color: AppTheme.notStartedColor,
                        onSelected: () { setState(() => _filterStatus = 0); _performSearch(provider); },
                      ),
                      const SizedBox(width: 4),
                      _StatusFilterChip(
                        label: 'In Progress',
                        selected: _filterStatus == 1,
                        color: AppTheme.inProgressColor,
                        onSelected: () { setState(() => _filterStatus = 1); _performSearch(provider); },
                      ),
                      const SizedBox(width: 4),
                      _StatusFilterChip(
                        label: 'Completed',
                        selected: _filterStatus == 2,
                        color: AppTheme.completedColor,
                        onSelected: () { setState(() => _filterStatus = 2); _performSearch(provider); },
                      ),
                      const SizedBox(width: 8),
                      // Date filter
                      ActionChip(
                        avatar: Icon(Icons.calendar_month, size: 16, color: _filterDate != null ? Colors.white : null),
                        label: Text(
                          _filterDate != null ? DateFormat('MMM d').format(_filterDate!) : 'Any Date',
                          style: TextStyle(fontSize: 11, color: _filterDate != null ? Colors.white : null),
                        ),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _filterDate ?? DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) {
                            setState(() => _filterDate = d);
                            _performSearch(provider);
                          }
                        },
                        backgroundColor: _filterDate != null ? colorScheme.primary : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      if (_filterDate != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() => _filterDate = null);
                            _performSearch(provider);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('Search or filter topics', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('No results found', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final topic = _results[index];
                          final subjectName = provider.subjectName(topic.subjectId);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(AppTheme.statusIcon(topic.status), color: AppTheme.statusColor(topic.status)),
                              title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text('$subjectName • ${topic.estimatedMinutes} min', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                              trailing: Chip(
                                label: Text(topic.statusLabel, style: TextStyle(fontSize: 11, color: AppTheme.statusColor(topic.status))),
                                backgroundColor: AppTheme.statusColor(topic.status).withValues(alpha: 0.12),
                                side: BorderSide.none,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({required this.label, required this.icon, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onChanged,
      itemBuilder: (_) => items.map((i) => PopupMenuItem<String?>(value: i.value, child: i.child)).toList(),
      child: Chip(
        avatar: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onSelected;
  const _StatusFilterChip({required this.label, required this.selected, this.color, required this.onSelected});
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color ?? Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
      visualDensity: VisualDensity.compact,
    );
  }
}
