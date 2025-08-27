import 'package:ai_study_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../components/widgets/greeting_section.dart';
import '../components/widgets/stat_card.dart';
import '../components/widgets/upcoming_section.dart';
import '../models/task.dart';
import '../models/task_service.dart';
import 'features/flashcard/flashcard_screen.dart';
import 'features/planner/planner_screen.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/chat/chatbot_screen.dart';

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
    await _taskService.updateTaskCompletion(taskId, isCompleted);
    _loadTodayTasks(); // Reload to get updated data
    // Force rebuild to refresh upcoming section
    setState(() {});
  }

  Future<void> _onTaskStarted(String taskId, bool isStarted) async {
    await _taskService.updateTaskStartStatus(taskId, isStarted);
    _loadTodayTasks(); // Reload to get updated data
    // Force rebuild to refresh upcoming section
    setState(() {});
  }

  int get completedTasksCount =>
      selectedDateTasks.where((task) => task.isCompleted).length;
  int get totalTasksCount => selectedDateTasks.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      title: "Your Average Score",
                      value: "68",
                      subtitle: "Quizzes taken: 12",
                      percentage: 0.68,
                      percentageText: "68.0%",
                    ),
                    const SizedBox(height: 16),
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
            color: Colors.black.withOpacity(0.1),
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
              color: Colors.pink.withOpacity(0.1),
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
}
