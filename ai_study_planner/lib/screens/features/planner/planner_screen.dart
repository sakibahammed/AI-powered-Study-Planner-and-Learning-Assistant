import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../models/task.dart';
import '../../../models/task_service.dart';
import '../../../components/widgets/edit_task_dialog.dart';

class PlannerScreen extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final VoidCallback? onTaskAdded;

  const PlannerScreen({super.key, this.onDateSelected, this.onTaskAdded});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen>
    with WidgetsBindingObserver {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  Map<DateTime, List<Task>> _events = {};
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;
    _loadTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTasks(); // Refresh when app resumes
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this screen
    _loadTasks();
  }

  void _loadTasks() {
    // Load existing tasks from service
    final allTasks = _taskService.getAllTasks();
    _events = {};

    for (final task in allTasks) {
      final dayKey = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      if (_events[dayKey] == null) {
        _events[dayKey] = [];
      }
      _events[dayKey]!.add(task);
    }
    setState(() {}); // Refresh UI to update statistics
  }



  List<Task> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Calculate task statistics for the selected date
  int get _totalTasksCount {
    final tasksForSelectedDay = _getEventsForDay(_selectedDay);

    return tasksForSelectedDay.length;
  }

  int get _completedTasksCount {
    final tasksForSelectedDay = _getEventsForDay(_selectedDay);
    final completedTasks = tasksForSelectedDay
        .where((task) => task.isCompleted)
        .toList();

    return completedTasks.length;
  }

  int get _inProgressTasksCount {
    final tasksForSelectedDay = _getEventsForDay(_selectedDay);
    final inProgressTasks = tasksForSelectedDay
        .where((task) => task.isStarted && !task.isCompleted)
        .toList();

    return inProgressTasks.length;
  }

  int get _pendingTasksCount {
    final tasksForSelectedDay = _getEventsForDay(_selectedDay);
    final pendingTasks = tasksForSelectedDay
        .where((task) => !task.isStarted && !task.isCompleted)
        .toList();

    return pendingTasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendar(),
                    const SizedBox(height: 24),
                    _buildStatisticsSection(),
                    const SizedBox(height: 24),
                    _buildTasksSection(),
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
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          const Text(
            'Planner',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          // Notify dashboard about the selected date
          widget.onDateSelected?.call(selectedDay);

        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.pink,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics for ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 120, // Fixed width for each card
                child: _buildStatCard(
                  'Total Tasks',
                  '$_totalTasksCount',
                  Icons.task,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120, // Fixed width for each card
                child: _buildStatCard(
                  'Completed',
                  '$_completedTasksCount',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120, // Fixed width for each card
                child: _buildStatCard(
                  'In Progress',
                  '$_inProgressTasksCount',
                  Icons.play_circle,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120, // Fixed width for each card
                child: _buildStatCard(
                  'Pending',
                  '$_pendingTasksCount',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 110, // Reduced height to prevent overflow
      width: 120, // Fixed width
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28), // Slightly smaller icon
          const SizedBox(height: 6), // Reduced spacing
          Text(
            value,
            style: const TextStyle(
              fontSize: 20, // Smaller font size
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4), // Small gap
          Text(
            title,
            style: TextStyle(
              fontSize: 11, // Smaller font size
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // Allow 2 lines if needed
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    final selectedDayEvents = _getEventsForDay(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks for ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => _showAddTaskDialog(context),
              child: const Text('Add Task'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (selectedDayEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No tasks for this day',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...selectedDayEvents.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Task header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getTaskStatusColor(task).withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTaskStatusColor(task),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTaskStatusIcon(task),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(task.category),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _getTaskStatusText(task),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getTaskStatusColor(task),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showEditTaskDialog(task),
                      icon: Icon(Icons.edit, color: Colors.grey[600]),
                      tooltip: 'Edit Task',
                    ),
                    IconButton(
                      onPressed: () => _deleteTask(task),
                      icon: Icon(Icons.delete, color: Colors.red[400]),
                      tooltip: 'Delete Task',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Task description
          if (task.description.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                task.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          // Action buttons
          Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    text: task.isStarted ? 'Started' : 'Start',
                    icon: Icons.play_arrow,
                    color: Colors.blue,
                    isActive: task.isStarted,
                    onPressed: (task.isStarted || task.isCompleted)
                        ? null
                        : () => _toggleTaskStart(task),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    text: task.isCompleted ? 'Completed' : 'Complete',
                    icon: Icons.check,
                    color: Colors.green,
                    isActive: task.isCompleted,
                    onPressed: (!task.isStarted || task.isCompleted)
                        ? null
                        : () => _toggleTaskCompletion(task),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required bool isActive,
    VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? color
              : (isDisabled ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.1)),
                  foregroundColor: isActive
            ? Colors.white
            : (isDisabled ? color.withValues(alpha: 0.6) : color.withValues(alpha: 0.8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : (isDisabled
                          ? color.withValues(alpha: 0.6)
                          : color.withValues(alpha: 0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTaskStatusColor(Task task) {
    if (task.isCompleted) return Colors.green;
    if (task.isStarted) return Colors.blue;
    return Colors.orange;
  }

  IconData _getTaskStatusIcon(Task task) {
    if (task.isCompleted) return Icons.check_circle;
    if (task.isStarted) return Icons.play_circle;
    return Icons.schedule;
  }

  String _getTaskStatusText(Task task) {
    if (task.isCompleted) return 'Completed';
    if (task.isStarted) return 'In Progress';
    return 'Pending';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Study':
        return Colors.blue;
      case 'Project':
        return Colors.orange;
      case 'Health':
        return Colors.green;
      case 'Personal':
        return Colors.purple;
      case 'Errands':
        return Colors.red;
      case 'Planning':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _toggleTaskCompletion(Task task) async {
    await _taskService.updateTaskCompletion(task.id, !task.isCompleted);
    _loadTasks(); // Reload tasks from service
    setState(() {});
  }

  void _toggleTaskStart(Task task) async {
    await _taskService.updateTaskStartStatus(task.id, !task.isStarted);
    _loadTasks(); // Reload tasks from service
    setState(() {});
  }

  void _updateTask(Task updatedTask) async {
    await _taskService.updateTask(updatedTask);
    _loadTasks(); // Reload tasks from service
    setState(() {});
    // Notify parent that a task was updated
    widget.onTaskAdded?.call();
  }

  void _deleteTask(Task task) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _taskService.removeTask(task.id);
      _loadTasks(); // Reload tasks from service
      setState(() {});

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      // Notify parent that a task was deleted
      widget.onTaskAdded?.call();
    }
  }

  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        onTaskUpdated: _updateTask,
        onTaskStarted: (taskId, isStarted) async {
          await _taskService.updateTaskStartStatus(taskId, isStarted);
          _loadTasks();
          setState(() {});
          // Notify parent that a task was updated
          widget.onTaskAdded?.call();
        },
        onTaskCompleted: (taskId, isCompleted) async {
          await _taskService.updateTaskCompletion(taskId, isCompleted);
          _loadTasks();
          setState(() {});
          // Notify parent that a task was updated
          widget.onTaskAdded?.call();
        },
        onTaskDeleted: (taskId) async {
          await _taskService.removeTask(taskId);
          if (mounted) {
            _loadTasks();
            setState(() {});
            // Notify parent that a task was deleted
            widget.onTaskAdded?.call();
          }
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(selectedDate: _selectedDay),
    );

    if (result != null) {
      await _taskService.addTask(result);
      if (mounted) {
        _loadTasks(); // Reload tasks from service
        setState(() {});
        // Notify parent that a task was added
        widget.onTaskAdded?.call();
      }
    }
  }
}

class AddTaskDialog extends StatefulWidget {
  final DateTime selectedDate;

  const AddTaskDialog({super.key, required this.selectedDate});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Study';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            onChanged: (value) {
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
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
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items:
                [
                  'Study',
                  'Project',
                  'Health',
                  'Personal',
                  'Errands',
                  'Planning',
                ].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              final task = Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                dueDate: widget.selectedDate,
                category: _selectedCategory,
              );
              Navigator.pop(context, task);
            } else {
              setState(() {
                _errorMessage = 'Task title is required';
              });
            }
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}
