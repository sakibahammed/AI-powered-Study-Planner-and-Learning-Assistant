import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../models/task.dart';
import '../../../models/task_service.dart';
import '../../../components/widgets/edit_task_dialog.dart';
import '../../../services/notification_service.dart';

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
      resizeToAvoidBottomInset: true, // This helps with keyboard handling
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) async {
              if (value == 'super_simple') {
                print('🔥 User requested SUPER SIMPLE notification...');
                final success = await NotificationService()
                    .superSimpleNotification();
                if (mounted) {
                  final message = success
                      ? '🔥 SUPER SIMPLE NOTIFICATION SENT! Check your notification bar!'
                      : 'Super simple failed. Check console for errors.';
                  final color = success ? Colors.orange : Colors.red;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'super_simple',
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('🔥 SUPER SIMPLE'),
                  ],
                ),
              ),
            ],
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
        // Notification Status Card
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.pink.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Smart Notifications',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tasks with time will get notified 5 minutes before',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                          // Show time if it's not midnight (00:00)
                          if (task.dueDate.hour != 0 ||
                              task.dueDate.minute != 0) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 10,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
              : (isDisabled
                    ? color.withValues(alpha: 0.3)
                    : color.withValues(alpha: 0.1)),
          foregroundColor: isActive
              ? Colors.white
              : (isDisabled
                    ? color.withValues(alpha: 0.6)
                    : color.withValues(alpha: 0.8)),
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
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _hasTime = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add_task, color: Colors.pink, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Task',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Create a new task for ${DateFormat('MMM dd, yyyy').format(widget.selectedDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
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
                      textInputAction: TextInputAction
                          .next, // Helps with keyboard navigation
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction
                          .done, // Helps with keyboard navigation
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                    // Beautiful Time Selection Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          // Time Display Header
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _hasTime
                                  ? Colors.pink.withOpacity(0.08)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: _hasTime
                                      ? Colors.pink.withOpacity(0.2)
                                      : Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _hasTime
                                        ? Colors.pink
                                        : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _hasTime
                                        ? [
                                            BoxShadow(
                                              color: Colors.pink.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Task Time',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _hasTime
                                            ? 'Scheduled for ${_selectedTime.format(context)}'
                                            : 'No specific time set',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _hasTime
                                              ? Colors.pink[700]
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Time Selection Controls
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final TimeOfDay?
                                      picked = await showTimePicker(
                                        context: context,
                                        initialTime: _selectedTime,
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: Colors.pink,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Colors.black87,
                                              ),
                                              dialogBackgroundColor:
                                                  Colors.white,
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedTime = picked;
                                          _hasTime = true;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _hasTime
                                              ? [
                                                  Colors.orange[400]!,
                                                  Colors.orange[500]!,
                                                ]
                                              : [
                                                  Colors.pink[400]!,
                                                  Colors.pink[500]!,
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                (_hasTime
                                                        ? Colors.orange
                                                        : Colors.pink)
                                                    .withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _hasTime
                                                ? Icons.edit
                                                : Icons.schedule,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            _hasTime
                                                ? 'Change Time'
                                                : 'Set Time',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                if (_hasTime) ...[
                                  SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _hasTime = false;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red[200]!,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.red[600],
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
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
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isNotEmpty) {
                          // Combine selected date with time if time is set
                          DateTime dueDate = widget.selectedDate;
                          if (_hasTime) {
                            dueDate = DateTime(
                              widget.selectedDate.year,
                              widget.selectedDate.month,
                              widget.selectedDate.day,
                              _selectedTime.hour,
                              _selectedTime.minute,
                            );
                          }

                          final task = Task(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            dueDate: dueDate,
                            category: _selectedCategory,
                          );
                          Navigator.pop(context, task);
                        } else {
                          setState(() {
                            _errorMessage = 'Task title is required';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
