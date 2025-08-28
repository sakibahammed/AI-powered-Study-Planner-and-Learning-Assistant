import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/streak.dart';

class StreakService {
  static const String _streakKey = 'user_streak';
  static StreakService? _instance;
  Streak? _currentStreak;

  StreakService._();

  static StreakService get instance {
    _instance ??= StreakService._();
    return _instance!;
  }

  // Initialize the streak service
  Future<void> initialize() async {
    await _loadStreak();
  }

  // Get current streak
  Streak get currentStreak => _currentStreak ?? Streak.initial();

  // Load streak from storage
  Future<void> _loadStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final streakJson = prefs.getString(_streakKey);

      if (streakJson != null) {
        final streakData = json.decode(streakJson);
        _currentStreak = Streak.fromJson(streakData);
      } else {
        _currentStreak = Streak.initial();
      }
    } catch (e) {
      print('Error loading streak: $e');
      _currentStreak = Streak.initial();
    }
  }

  // Save streak to storage
  Future<void> _saveStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final streakJson = json.encode(_currentStreak!.toJson());
      await prefs.setString(_streakKey, streakJson);
    } catch (e) {
      print('Error saving streak: $e');
    }
  }

  // Check if user can earn streak for today
  bool canEarnStreakToday() {
    if (_currentStreak == null) return true;

    final today = DateTime.now();
    final lastCompleted = _currentStreak!.lastCompletedDate;

    // Check if we already earned streak today
    if (_currentStreak!.isToday(lastCompleted)) {
      return false;
    }

    return true;
  }

  // Earn streak for today (called when user completes a task)
  Future<void> earnStreakForToday() async {
    if (!canEarnStreakToday()) {
      print('Already earned streak for today');
      return;
    }

    final today = DateTime.now();

    if (_currentStreak == null) {
      _currentStreak = Streak.initial();
    }

    // Check if this is consecutive to the last completed date
    if (_currentStreak!.isConsecutive(today)) {
      // Continue the streak
      _currentStreak = Streak(
        currentStreak: _currentStreak!.currentStreak + 1,
        longestStreak:
            (_currentStreak!.currentStreak + 1 > _currentStreak!.longestStreak)
            ? _currentStreak!.currentStreak + 1
            : _currentStreak!.longestStreak,
        lastCompletedDate: today,
        completedDates: [..._currentStreak!.completedDates, today],
      );
    } else if (_currentStreak!.isYesterday(_currentStreak!.lastCompletedDate)) {
      // Break in streak, start new one
      _currentStreak = Streak(
        currentStreak: 1,
        longestStreak: _currentStreak!.longestStreak,
        lastCompletedDate: today,
        completedDates: [..._currentStreak!.completedDates, today],
      );
    } else {
      // Gap in streak, start new one
      _currentStreak = Streak(
        currentStreak: 1,
        longestStreak: _currentStreak!.longestStreak,
        lastCompletedDate: today,
        completedDates: [..._currentStreak!.completedDates, today],
      );
    }

    await _saveStreak();
    print('Streak updated: ${_currentStreak!.currentStreak} days');
  }

  // Reset streak (for testing or user preference)
  Future<void> resetStreak() async {
    _currentStreak = Streak.initial();
    await _saveStreak();
  }

  // Get streak statistics
  Map<String, dynamic> getStreakStats() {
    if (_currentStreak == null) return {};

    return {
      'currentStreak': _currentStreak!.currentStreak,
      'longestStreak': _currentStreak!.longestStreak,
      'lastCompletedDate': _currentStreak!.lastCompletedDate,
      'completedDates': _currentStreak!.completedDates,
      'canEarnToday': canEarnStreakToday(),
      'streakMessage': _currentStreak!.getStreakMessage(),
      'streakEmoji': _currentStreak!.getStreakEmoji(),
    };
  }

  // Check if streak is about to break (missed yesterday)
  bool isStreakAboutToBreak() {
    if (_currentStreak == null || _currentStreak!.currentStreak == 0)
      return false;

    final today = DateTime.now();
    final lastCompleted = _currentStreak!.lastCompletedDate;

    // If last completed was 2 or more days ago, streak is broken
    final difference = today.difference(lastCompleted).inDays;
    return difference >= 2;
  }

  // Get motivational message based on streak status
  String getMotivationalMessage() {
    if (_currentStreak == null || _currentStreak!.currentStreak == 0) {
      return 'Start your journey today! Every great streak begins with a single step.';
    }

    if (isStreakAboutToBreak()) {
      return 'Don\'t let your streak break! Complete a task today to keep it alive!';
    }

    if (_currentStreak!.currentStreak == 1) {
      return 'Great start! Complete a task tomorrow to build your streak!';
    }

    return 'Amazing! You\'re on a ${_currentStreak!.currentStreak}-day streak! Keep it going!';
  }
}
