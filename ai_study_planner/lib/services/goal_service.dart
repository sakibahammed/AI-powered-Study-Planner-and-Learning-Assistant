import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';

class GoalService {
  static const String _goalKey = 'user_goals';
  static GoalService? _instance;
  Goal? _currentGoal;

  GoalService._();

  static GoalService get instance {
    _instance ??= GoalService._();
    return _instance!;
  }

  // Initialize the goal service
  Future<void> initialize() async {
    await _loadGoal();
  }

  // Load goal from storage
  Future<void> _loadGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalJson = prefs.getString(_goalKey);

      if (goalJson != null) {
        final goalData = json.decode(goalJson);
        _currentGoal = Goal.fromJson(goalData);
      } else {
        _currentGoal = Goal.defaultGoal();
      }
    } catch (e) {
      print('Error loading goal: $e');
      _currentGoal = Goal.defaultGoal();
    }
  }

  // Save goal to storage
  Future<void> _saveGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalJson = json.encode(_currentGoal!.toJson());
      await prefs.setString(_goalKey, goalJson);
    } catch (e) {
      print('Error saving goal: $e');
    }
  }

  // Get current goal
  Goal get currentGoal => _currentGoal ?? Goal.defaultGoal();

  // Update daily goal
  Future<void> updateDailyGoal(int newDailyGoal) async {
    _currentGoal =
        _currentGoal?.copyWith(
          dailyGoal: newDailyGoal,
          lastUpdated: DateTime.now(),
        ) ??
        Goal.defaultGoal();

    await _saveGoal();
    print('📊 Daily goal updated to: $newDailyGoal tasks');
  }

  // Update weekly goal
  Future<void> updateWeeklyGoal(int newWeeklyGoal) async {
    _currentGoal =
        _currentGoal?.copyWith(
          weeklyGoal: newWeeklyGoal,
          lastUpdated: DateTime.now(),
        ) ??
        Goal.defaultGoal();

    await _saveGoal();
    print('📊 Weekly goal updated to: $newWeeklyGoal tasks');
  }

  // Update both goals
  Future<void> updateGoals({int? dailyGoal, int? weeklyGoal}) async {
    _currentGoal =
        _currentGoal?.copyWith(
          dailyGoal: dailyGoal,
          weeklyGoal: weeklyGoal,
          lastUpdated: DateTime.now(),
        ) ??
        Goal.defaultGoal();

    await _saveGoal();
    print(
      '📊 Goals updated - Daily: ${_currentGoal!.dailyGoal}, Weekly: ${_currentGoal!.weeklyGoal}',
    );
  }

  // Reset to default goals
  Future<void> resetToDefault() async {
    _currentGoal = Goal.defaultGoal();
    await _saveGoal();
    print('📊 Goals reset to default');
  }

  // Get goal statistics
  Map<String, dynamic> getGoalStats() {
    if (_currentGoal == null) return {};

    return {
      'dailyGoal': _currentGoal!.dailyGoal,
      'weeklyGoal': _currentGoal!.weeklyGoal,
      'lastUpdated': _currentGoal!.lastUpdated,
    };
  }
}
