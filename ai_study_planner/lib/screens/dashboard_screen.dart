import 'package:ai_study_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../components/widgets/greeting_section.dart';
import '../components/widgets/stat_card.dart';
import '../components/widgets/upcoming_section.dart';
import '../models/task.dart';
import '../models/task_service.dart';
import 'features/flashcard/flashcard_screen.dart';
import 'features/planner/planner_screen.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/chat/chatbot_screen.dart';
import 'features/progress/progress_screen.dart';

class DashboardScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const DashboardScreen({super.key, this.selectedDate});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  List<Task> selectedDateTasks = [];
  final TaskService _taskService = TaskService();
  bool _isLoading = true;
  late DateTime _currentSelectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentSelectedDate = widget.selectedDate ?? DateTime.now();
    _initializeTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeTasks() async {
    await _taskService.initialize();
    _loadTodayTasks();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTodayTasks();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload tasks when returning to this screen
    _loadTodayTasks();
  }

  void _loadTodayTasks() {
    print('Dashboard: _loadTodayTasks called');
    setState(() {
      selectedDateTasks = _taskService.getTasksForDate(_currentSelectedDate);
    });
  }

  void updateSelectedDate(DateTime newDate) {
    setState(() {
      _currentSelectedDate = newDate;
      _loadTodayTasks();
    });
  }

  String _getDateTitle() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _currentSelectedDate.year,
      _currentSelectedDate.month,
      _currentSelectedDate.day,
    );

    if (selectedDate == today) {
      return "Today's Tasks";
    } else if (selectedDate == today.add(Duration(days: 1))) {
      return "Tomorrow's Tasks";
    } else {
      return "${_currentSelectedDate.day} ${_getMonthName(_currentSelectedDate.month)} Tasks";
    }
  }

  String _getNoTasksMessage() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _currentSelectedDate.year,
      _currentSelectedDate.month,
      _currentSelectedDate.day,
    );

    if (selectedDate == today) {
      return "No tasks for today";
    } else if (selectedDate == today.add(Duration(days: 1))) {
      return "No tasks for tomorrow";
    } else {
      return "No tasks for ${_currentSelectedDate.day} ${_getMonthName(_currentSelectedDate.month)}";
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  Future<void> _onTaskCompleted(String taskId, bool isCompleted) async {
    try {
      await _taskService.updateTaskCompletion(taskId, isCompleted);
      _loadTodayTasks(); // Reload to get updated data
      // Force rebuild to refresh upcoming section
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error completing task: $e');
      // Show error to user if needed
    }
  }

  Future<void> _onTaskStarted(String taskId, bool isStarted) async {
    try {
      await _taskService.updateTaskStartStatus(taskId, isStarted);
      _loadTodayTasks(); // Reload to get updated data
      // Force rebuild to refresh upcoming section
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error starting task: $e');
      // Show error to user if needed
    }
  }

  int get completedTasksCount =>
      selectedDateTasks.where((task) => task.isCompleted).length;
  int get totalTasksCount => selectedDateTasks.length;

  // Get currently active (started but not completed) tasks
  List<Task> get activeTasks {
    try {
      return selectedDateTasks
          .where((task) => task.isStarted && !task.isCompleted)
          .toList();
    } catch (e) {
      print('Error getting active tasks: $e');
      return [];
    }
  }

  Widget _buildActiveTaskSection() {
    if (activeTasks.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no active tasks
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔥 Currently Working On',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...activeTasks.map((task) => _buildActiveTaskCard(task)),
      ],
    );
  }

  Widget _buildActiveTaskCard(Task task) {
    return GestureDetector(
      onLongPress: () {
        _showCompletionConfirmation(context, task);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[400]!, Colors.orange[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Navigate to planner or show task details
            },
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  // Cool loading spinner
                  Container(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        // Rotating outer ring
                        TweenAnimationBuilder<double>(
                          duration: Duration(seconds: 2),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: value * 2 * 3.14159,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white.withOpacity(0.8),
                                      width: 3,
                                    ),
                                    right: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 3,
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 3,
                                    ),
                                    left: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Pulsing center dot
                        TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 1500),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Center(
                              child: Container(
                                width: 12 * (0.8 + 0.2 * value),
                                height: 12 * (0.8 + 0.2 * value),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'In Progress',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Simple animated dots
                            Row(
                              children: List.generate(3, (index) {
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 1200),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    final delay = index * 0.2;
                                    final opacity = (value - delay).clamp(
                                      0.0,
                                      1.0,
                                    );
                                    return Container(
                                      width: 4,
                                      height: 4,
                                      margin: EdgeInsets.only(right: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(
                                          opacity,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Completion hint icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true, // This helps with keyboard handling
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GreetingSection(),
                    const SizedBox(height: 20),
                    StatCard(
                      title: _getDateTitle(),
                      value: totalTasksCount == 0
                          ? "0"
                          : "$completedTasksCount",
                      subtitle: totalTasksCount == 0
                          ? _getNoTasksMessage()
                          : "out of $totalTasksCount",
                      percentage: totalTasksCount > 0
                          ? completedTasksCount / totalTasksCount
                          : 0,
                      percentageText: totalTasksCount > 0
                          ? "${((completedTasksCount / totalTasksCount) * 100).toStringAsFixed(1)}%"
                          : "0%",
                      tasks: selectedDateTasks,
                      onTaskCompleted: _onTaskCompleted,
                      onTaskStarted: _onTaskStarted,
                    ),
                    const SizedBox(height: 24),
                    _buildActiveTaskSection(),
                    const SizedBox(height: 24),
                    UpcomingSection(),
                    const SizedBox(height: 100), // Extra space for bottom nav
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.menu_book,
                label: 'Flashcard',
                onTap: () => _navigateToScreen(FlashcardPage()),
              ),
              _buildNavItem(
                icon: Icons.calendar_today,
                label: 'Planner',
                onTap: () => _navigateToScreen(
                  PlannerScreen(
                    onDateSelected: updateSelectedDate,
                    onTaskAdded: () {
                      print(
                        'Dashboard: Task added callback received, refreshing...',
                      );
                      _loadTodayTasks();
                      setState(() {});
                    },
                  ),
                ),
              ),
              _buildNavItem(
                icon: Icons.quiz,
                label: 'Quiz',
                onTap: () => _navigateToScreen(QuizScreen()),
              ),
              _buildNavItem(
                icon: Icons.chat_bubble,
                label: 'Studybot',
                onTap: () => _navigateToScreen(ChatbotScreen()),
              ),
              _buildNavItem(
                icon: Icons.trending_up,
                label: 'Progress',
                onTap: () => _navigateToScreen(ProgressScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.pink, size: 24),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    // Refresh tasks when returning from planner
    _loadTodayTasks();
    // Force rebuild to refresh upcoming section
    setState(() {});
  }

  void _showCompletionConfirmation(BuildContext context, Task task) {
    // Generate dynamic questions based on task type
    List<String> questions = _generateCompletionQuestions(task);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: Offset(0, 15),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with task title
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[400]!, Colors.orange[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.task_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Complete Task',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Task title
              Text(
                '"${task.title}"',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Confirmation questions
              ...questions.map(
                (question) => Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.orange[600],
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          Navigator.pop(context);
                          _showCompletionCelebration(context, task);
                          await _onTaskCompleted(task.id, true);
                        } catch (e) {
                          print('Error in completion button: $e');
                          // Show error to user if needed
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.orange.withOpacity(0.3),
                      ),
                      child: Text(
                        'Complete Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _generateCompletionQuestions(Task task) {
    // Generate dynamic questions based on task type/category
    List<String> baseQuestions = [
      'Did you complete this task?',
      'Are you satisfied with the result?',
    ];

    // Add category-specific questions with null safety
    final category = task.category;
    if (category != null && category.isNotEmpty) {
      String categoryLower = category.toLowerCase();
      if (categoryLower.contains('study') || categoryLower.contains('read')) {
        baseQuestions.add('Did you understand the material?');
        baseQuestions.add('Would you like to review it later?');
      } else if (categoryLower.contains('exercise') ||
          categoryLower.contains('workout')) {
        baseQuestions.add('Did you complete all sets/reps?');
        baseQuestions.add('How do you feel after the workout?');
      } else if (categoryLower.contains('project') ||
          categoryLower.contains('work')) {
        baseQuestions.add('Did you meet all requirements?');
        baseQuestions.add('Is the project ready for review?');
      } else if (categoryLower.contains('homework') ||
          categoryLower.contains('assignment')) {
        baseQuestions.add('Did you check your work?');
        baseQuestions.add('Are you confident in your answers?');
      }
    }

    // Add general completion question
    baseQuestions.add('Ready to mark this task as complete?');

    return baseQuestions;
  }

  void _showCompletionCelebration(BuildContext context, Task task) {
    // Show a celebration overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration icon with animation
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.5 + 0.5 * value,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
              Text(
                '🎉 Task Completed! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '"${task.title}"',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Great job! Keep up the momentum! 💪',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    // Auto-close after 2 seconds
    Timer(Duration(seconds: 2), () {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }
}
