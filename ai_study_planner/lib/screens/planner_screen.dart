import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../models/task.dart'; // Ensure Task can map to/from Firestore (see note below)

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  // Local cache of events for TableCalendar eventLoader
  Map<DateTime, List<Task>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
  }

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Month range helpers (inclusive start, exclusive end)
  DateTime _monthStart(DateTime any) => DateTime(any.year, any.month, 1);
  DateTime _monthEnd(DateTime any) =>
      DateTime(any.year, any.month + 1, 1); // exclusive

  Stream<List<Task>> _tasksStreamForMonth(DateTime monthCenter) {
    final start = _monthStart(monthCenter);
    final end = _monthEnd(monthCenter);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => snap.docs.map((d) => Task.fromFirestore(d)).toList());
  }

  List<Task> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  // Build a map<DateOnly, List<Task>> for calendar markers & daily list
  Map<DateTime, List<Task>> _groupByDay(List<Task> tasks) {
    final map = <DateTime, List<Task>>{};
    for (final t in tasks) {
      final dt = DateTime(t.date.year, t.date.month, t.date.day);
      map.putIfAbsent(dt, () => []).add(t);
    }
    return map;
  }

  // Quick stats from current month snapshot
  ({int total, int completed, int pending}) _stats(List<Task> tasks) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;
    return (total: total, completed: completed, pending: pending);
  }

  // Weekly progress: completed count per weekday (Mon..Sun = 0..6)
  List<FlSpot> _weeklyProgress(List<Task> tasks) {
    // Use current week (Mon..Sun) around _focusedDay
    final now = _focusedDay;
    final monday = now.subtract(Duration(days: (now.weekday + 6) % 7)); // Mon
    final counts = List<int>.filled(7, 0);

    for (final t in tasks) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (d.isAfter(monday.subtract(const Duration(days: 1))) &&
          d.isBefore(monday.add(const Duration(days: 7)))) {
        final idx = (d.weekday + 6) % 7; // Mon=0..Sun=6
        if (t.isCompleted) counts[idx] += 1;
      }
    }

    return List<FlSpot>.generate(7, (i) => FlSpot(i.toDouble(), counts[i].toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: _tasksStreamForMonth(_focusedDay),
      builder: (context, snap) {
        final tasks = snap.data ?? [];

        // Update event map for the calendar
        _events = _groupByDay(tasks);

        final s = _stats(tasks);
        final weeklySpots = _weeklyProgress(tasks);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (snap.connectionState == ConnectionState.waiting)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendar(),
                        const SizedBox(height: 24),
                        _buildStatisticsSection(total: s.total, completed: s.completed, pending: s.pending),
                        const SizedBox(height: 24),
                        _buildTasksSection(_getEventsForDay(_selectedDay)),
                        const SizedBox(height: 24),
                        _buildProgressChart(weeklySpots),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context),
            backgroundColor: Colors.pink,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          ),
          const SizedBox(width: 8),
          const Text(
            'Study Planner',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 18, 1, 1)),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        ),
        headerStyle: const HeaderStyle(formatButtonVisible: true, titleCentered: true, formatButtonShowsNext: false),
      ),
    );
  }

  Widget _buildStatisticsSection({required int total, required int completed, required int pending}) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Tasks', '$total', Icons.task, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Completed', '$completed', Icons.check_circle, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Pending', '$pending', Icons.pending, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTasksSection(List<Task> selectedDayEvents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'Tasks for ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          TextButton(onPressed: () => _showAddTaskDialog(context), child: const Text('Add Task')),
        ]),
        const SizedBox(height: 12),
        if (selectedDayEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Column(children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('No tasks for this day', style: TextStyle(color: Colors.grey)),
              ]),
            ),
          )
        else
          ...selectedDayEvents.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: _getPriorityColor(task.priority), shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              if (task.description.isNotEmpty)
                Text(task.description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ]),
          ),
          IconButton(
            onPressed: () => _toggleTaskCompletion(task),
            icon: Icon(task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: task.isCompleted ? Colors.green : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(List<FlSpot> spots) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 1),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final i = value.toInt();
                        return (i >= 0 && i < days.length) ? Text(days[i]) : const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.pink,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.pink.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    // Update in Firestore; the stream will refresh UI
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('tasks')
        .doc(task.id)
        .update({'isCompleted': !task.isCompleted});
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AddTaskDialog(
        selectedDate: _selectedDay,
        onSubmit: (title, description, priority) async {
          final doc = FirebaseFirestore.instance
              .collection('users')
              .doc(_uid)
              .collection('tasks')
              .doc();
          await doc.set({
            'title': title,
            'description': description,
            'priority': priority.name, // store as string
            'date': Timestamp.fromDate(DateTime(
              _selectedDay.year,
              _selectedDay.month,
              _selectedDay.day,
              12, // noon to avoid DST edge cases
            )),
            'isCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        },
      ),
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Future<void> Function(String title, String description, TaskPriority priority) onSubmit;

  const AddTaskDialog({super.key, required this.selectedDate, required this.onSubmit});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _errorMessage;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
            decoration: InputDecoration(
              labelText: 'Task Title',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TaskPriority>(
            value: _selectedPriority,
            decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
            items: TaskPriority.values
                .map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase())))
                .toList(),
            onChanged: (value) => setState(() => _selectedPriority = value!),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _saving
              ? null
              : () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) {
                    setState(() => _errorMessage = 'Task title is required');
                    return;
                  }
                  setState(() => _saving = true);
                  try {
                    await widget.onSubmit(title, _descriptionController.text.trim(), _selectedPriority);
                    if (context.mounted) Navigator.pop(context);
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add Task'),
        ),
      ],
    );
  }
}
