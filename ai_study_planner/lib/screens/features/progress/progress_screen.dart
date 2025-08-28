import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/streak_service.dart';
import '../../../services/timing_service.dart';
import '../../../services/goal_service.dart';
import '../../../models/streak.dart';
import '../../../models/goal.dart';
import '../../../models/task_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final StreakService _streakService = StreakService.instance;
  final TimingService _timingService = TimingService.instance;
  final GoalService _goalService = GoalService.instance;
  Streak? _currentStreak;
  Goal? _currentGoal;
  Map<String, String> _timingStats = {};
  Map<String, int> _weeklyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _streakService.initialize();
      await _timingService.initialize();
      await _goalService.initialize();

      // Calculate weekly completion data
      _calculateWeeklyData();

      setState(() {
        _currentStreak = _streakService.currentStreak;
        _currentGoal = _goalService.currentGoal;
        _timingStats = _timingService.getTimingStats();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateWeeklyData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    _weeklyData.clear();

    // Get completion data for each day of the week
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final completedTasks = _getCompletedTasksForDate(date);
      _weeklyData[dayName] = completedTasks;
    }
  }

  int _getCompletedTasksForDate(DateTime date) {
    try {
      final taskService = TaskService();
      final tasksForDate = taskService.getTasksForDate(date);
      return tasksForDate.where((task) => task.isCompleted).length;
    } catch (e) {
      print('Error getting completed tasks for date: $e');
      return 0;
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  void _showGoalSettings() {
    final currentGoal = _currentGoal ?? Goal.defaultGoal();
    final dailyController = TextEditingController(
      text: currentGoal.dailyGoal.toString(),
    );
    final weeklyController = TextEditingController(
      text: currentGoal.weeklyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Your Goals'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dailyController,
              decoration: InputDecoration(
                labelText: 'Daily Goal (tasks)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: weeklyController,
              decoration: InputDecoration(
                labelText: 'Weekly Goal (tasks)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dailyGoal =
                  int.tryParse(dailyController.text) ?? currentGoal.dailyGoal;
              final weeklyGoal =
                  int.tryParse(weeklyController.text) ?? currentGoal.weeklyGoal;

              await _goalService.updateGoals(
                dailyGoal: dailyGoal,
                weeklyGoal: weeklyGoal,
              );
              Navigator.pop(context);
              _loadData(); // Refresh data
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Progress',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => _loadData(),
            tooltip: 'Refresh data',
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Streak Card
              _buildStreakCard(),
              const SizedBox(height: 24),

              // Task Completion Time Card
              _buildCompletionTimeCard(),
              const SizedBox(height: 24),

              // Weekly Progress Card
              _buildWeeklyProgressCard(),
              const SizedBox(height: 24),

              // Study Insights
              _buildStudyInsights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[400]!, Colors.deepOrange[400]!],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final streak = _currentStreak ?? Streak.initial();
    final canEarnToday = _streakService.canEarnStreakToday();
    final streakMessage = streak.getStreakMessage();
    final streakEmoji = streak.getStreakEmoji();

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[400]!, Colors.deepOrange[400]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streakEmoji Daily Streak',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${streak.currentStreak} Days',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      streakMessage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Streak status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  canEarnToday ? Icons.check_circle : Icons.schedule,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  canEarnToday
                      ? 'Streak available today!'
                      : 'Streak earned today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (streak.longestStreak > 0) ...[
            SizedBox(height: 12),
            Text(
              '🏆 Longest streak: ${streak.longestStreak} days',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionTimeCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.timer, color: Colors.blue[600], size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Task Time',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'How long you take to complete tasks',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Average Time per Task',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeMetric(
                'Today',
                _timingStats['avgToday'] ?? '0m',
                Colors.green,
              ),
              _buildTimeMetric(
                'This Week',
                _timingStats['avgWeek'] ?? '0m',
                Colors.blue,
              ),
              _buildTimeMetric(
                'This Month',
                _timingStats['avgMonth'] ?? '0m',
                Colors.purple,
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Total Time Spent',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeMetric(
                'Today',
                _timingStats['totalToday'] ?? '0m',
                Colors.orange,
              ),
              _buildTimeMetric(
                'This Week',
                _timingStats['totalWeek'] ?? '0m',
                Colors.red,
              ),
              _buildTimeMetric(
                'This Month',
                _timingStats['totalMonth'] ?? '0m',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMetric(String label, String time, Color color) {
    return Column(
      children: [
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.green[600],
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Task Completion',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Daily goal: ${_currentGoal?.dailyGoal ?? 5} tasks',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showGoalSettings,
                icon: Icon(Icons.settings, color: Colors.grey[600]),
                tooltip: 'Set Goals',
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final goal = _currentGoal ?? Goal.defaultGoal();
    final maxValue = _weeklyData.values.isEmpty
        ? 1
        : _weeklyData.values.reduce((a, b) => a > b ? a : b);
    final maxBarHeight = 120.0;
    final goalLineHeight =
        (goal.dailyGoal / (maxValue == 0 ? 1 : maxValue)) * maxBarHeight;
    final totalCompleted = _weeklyData.values.fold(
      0,
      (sum, count) => sum + count,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$totalCompleted tasks completed',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Goal: ${goal.weeklyGoal}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Chart container
        Container(
          height: maxBarHeight + 40,
          child: Stack(
            children: [
              // Goal line
              Positioned(
                top: maxBarHeight - goalLineHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              // Bars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _weeklyData.entries.map((entry) {
                  final dayName = entry.key;
                  final completedTasks = entry.value;
                  final barHeight = maxValue == 0
                      ? 0.0
                      : (completedTasks / maxValue) * maxBarHeight;
                  final isGoalMet = completedTasks >= goal.dailyGoal;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bar
                      Container(
                        width: 30,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isGoalMet
                                ? [Colors.green[400]!, Colors.green[600]!]
                                : [Colors.blue[400]!, Colors.blue[600]!],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: (isGoalMet ? Colors.green : Colors.blue)
                                  .withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),

                      // Day name
                      Text(
                        dayName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Task count
                      Text(
                        '$completedTasks',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Goal line legend
        Row(
          children: [
            Container(
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Daily Goal (${goal.dailyGoal} tasks)',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudyInsights() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[400]!, Colors.pink[400]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.psychology, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Study Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInsightRow(
            'Best Study Time',
            'Morning (9 AM - 11 AM)',
            Icons.wb_sunny,
          ),
          SizedBox(height: 16),
          _buildInsightRow(
            'Most Productive Day',
            'Wednesday',
            Icons.calendar_today,
          ),
          SizedBox(height: 16),
          _buildInsightRow('Focus Duration', '45 minutes average', Icons.timer),
          SizedBox(height: 16),
          _buildInsightRow(
            'Break Efficiency',
            '15 min breaks work best',
            Icons.coffee,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
