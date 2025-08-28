import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TimingService {
  static const String _timingKey = 'task_timing_data';
  static TimingService? _instance;
  List<TaskTimingData> _timingData = [];

  TimingService._();

  static TimingService get instance {
    _instance ??= TimingService._();
    return _instance!;
  }

  // Initialize the timing service
  Future<void> initialize() async {
    await _loadTimingData();
  }

  // Load timing data from storage
  Future<void> _loadTimingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timingJson = prefs.getString(_timingKey);

      if (timingJson != null) {
        final List<dynamic> data = json.decode(timingJson);
        _timingData = data
            .map((item) => TaskTimingData.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error loading timing data: $e');
      _timingData = [];
    }
  }

  // Save timing data to storage
  Future<void> _saveTimingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timingJson = json.encode(
        _timingData.map((data) => data.toJson()).toList(),
      );
      await prefs.setString(_timingKey, timingJson);
    } catch (e) {
      print('Error saving timing data: $e');
    }
  }

  // Record task start time
  Future<void> recordTaskStart(String taskId) async {
    final startTime = DateTime.now();

    // Remove any existing incomplete timing data for this task
    _timingData.removeWhere(
      (data) => data.taskId == taskId && data.completionTime == null,
    );

    // Add new timing data
    _timingData.add(
      TaskTimingData(
        taskId: taskId,
        startTime: startTime,
        completionTime: null,
        completionDuration: null,
      ),
    );

    await _saveTimingData();
    print('📝 Task start time recorded for task: $taskId');
  }

  // Record task completion time
  Future<void> recordTaskCompletion(String taskId) async {
    final completionTime = DateTime.now();

    // Find the timing data for this task
    final timingIndex = _timingData.indexWhere(
      (data) => data.taskId == taskId && data.completionTime == null,
    );

    if (timingIndex != -1) {
      final timingData = _timingData[timingIndex];
      final duration = completionTime.difference(timingData.startTime);

      // Update the timing data
      _timingData[timingIndex] = TaskTimingData(
        taskId: taskId,
        startTime: timingData.startTime,
        completionTime: completionTime,
        completionDuration: duration,
      );

      await _saveTimingData();
      print(
        '✅ Task completion time recorded for task: $taskId (Duration: ${_formatDuration(duration)})',
      );
    } else {
      print('⚠️ No start time found for task: $taskId');
    }
  }

  // Get average completion time for today
  Duration getAverageCompletionTimeToday() {
    final today = DateTime.now();
    final todayData = _timingData.where((data) {
      return data.completionTime != null &&
          data.completionTime!.year == today.year &&
          data.completionTime!.month == today.month &&
          data.completionTime!.day == today.day;
    }).toList();

    if (todayData.isEmpty) return Duration.zero;

    final totalDuration = todayData.fold<Duration>(
      Duration.zero,
      (total, data) => total + (data.completionDuration ?? Duration.zero),
    );

    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ todayData.length,
    );
  }

  // Get average completion time for this week
  Duration getAverageCompletionTimeThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final weekData = _timingData.where((data) {
      return data.completionTime != null &&
          data.completionTime!.isAfter(
            startOfWeek.subtract(Duration(days: 1)),
          ) &&
          data.completionTime!.isBefore(endOfWeek.add(Duration(days: 1)));
    }).toList();

    if (weekData.isEmpty) return Duration.zero;

    final totalDuration = weekData.fold<Duration>(
      Duration.zero,
      (total, data) => total + (data.completionDuration ?? Duration.zero),
    );

    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ weekData.length,
    );
  }

  // Get average completion time for this month
  Duration getAverageCompletionTimeThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthData = _timingData.where((data) {
      return data.completionTime != null &&
          data.completionTime!.isAfter(
            startOfMonth.subtract(Duration(days: 1)),
          ) &&
          data.completionTime!.isBefore(endOfMonth.add(Duration(days: 1)));
    }).toList();

    if (monthData.isEmpty) return Duration.zero;

    final totalDuration = monthData.fold<Duration>(
      Duration.zero,
      (total, data) => total + (data.completionDuration ?? Duration.zero),
    );

    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ monthData.length,
    );
  }

  // Get total completion time for today
  Duration getTotalCompletionTimeToday() {
    final today = DateTime.now();
    final todayData = _timingData.where((data) {
      return data.completionTime != null &&
          data.completionTime!.year == today.year &&
          data.completionTime!.month == today.month &&
          data.completionTime!.day == today.day;
    }).toList();

    return todayData.fold<Duration>(
      Duration.zero,
      (total, data) => total + (data.completionDuration ?? Duration.zero),
    );
  }

  // Get total completion time for this week
  Duration getTotalCompletionTimeThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final weekData = _timingData.where((data) {
      return data.completionTime != null &&
          data.completionTime!.isAfter(
            startOfWeek.subtract(Duration(days: 1)),
          ) &&
          data.completionTime!.isBefore(endOfWeek.add(Duration(days: 1)));
    }).toList();

    return weekData.fold<Duration>(
      Duration.zero,
      (total, data) => total + (data.completionDuration ?? Duration.zero),
    );
  }

  // Get total completion time for this month
  Duration getTotalCompletionTimeThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthData = _timingData.where((data) {
      return data.completionTime != null &&
          data.completionTime!.isAfter(
            startOfMonth.subtract(Duration(days: 1)),
          ) &&
          data.completionTime!.isBefore(endOfMonth.add(Duration(days: 1)));
    }).toList();

    return monthData.fold<Duration>(
      Duration.zero,
      (total, data) => total + (data.completionDuration ?? Duration.zero),
    );
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get formatted timing statistics
  Map<String, String> getTimingStats() {
    final avgToday = getAverageCompletionTimeToday();
    final avgWeek = getAverageCompletionTimeThisWeek();
    final avgMonth = getAverageCompletionTimeThisMonth();

    final totalToday = getTotalCompletionTimeToday();
    final totalWeek = getTotalCompletionTimeThisWeek();
    final totalMonth = getTotalCompletionTimeThisMonth();

    return {
      'avgToday': _formatDuration(avgToday),
      'avgWeek': _formatDuration(avgWeek),
      'avgMonth': _formatDuration(avgMonth),
      'totalToday': _formatDuration(totalToday),
      'totalWeek': _formatDuration(totalWeek),
      'totalMonth': _formatDuration(totalMonth),
    };
  }

  // Clear all timing data (for testing)
  Future<void> clearAllTimingData() async {
    _timingData.clear();
    await _saveTimingData();
  }
}

// Data class for storing task timing information
class TaskTimingData {
  final String taskId;
  final DateTime startTime;
  final DateTime? completionTime;
  final Duration? completionDuration;

  TaskTimingData({
    required this.taskId,
    required this.startTime,
    this.completionTime,
    this.completionDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'startTime': startTime.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'completionDuration': completionDuration?.inMilliseconds,
    };
  }

  factory TaskTimingData.fromJson(Map<String, dynamic> json) {
    return TaskTimingData(
      taskId: json['taskId'],
      startTime: DateTime.parse(json['startTime']),
      completionTime: json['completionTime'] != null
          ? DateTime.parse(json['completionTime'])
          : null,
      completionDuration: json['completionDuration'] != null
          ? Duration(milliseconds: json['completionDuration'])
          : null,
    );
  }
}
