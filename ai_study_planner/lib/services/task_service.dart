import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final List<Task> _allTasks = [];
  static const String _storageKey = 'tasks';

  // Initialize and load tasks from storage
  Future<void> initialize() async {
    await _loadTasksFromStorage();
  }

  // Load tasks from shared preferences
  Future<void> _loadTasksFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_storageKey) ?? [];

      _allTasks.clear();
      for (final taskJson in tasksJson) {
        try {
          final taskMap = json.decode(taskJson);
          final task = Task.fromMap(taskMap);
          _allTasks.add(task);
        } catch (e) {
          print('TaskService: Error parsing task: $e');
        }
      }
      print('TaskService: Loaded ${_allTasks.length} tasks from storage');
    } catch (e) {
      print('TaskService: Error loading tasks from storage: $e');
    }
  }

  // Save tasks to shared preferences
  Future<void> _saveTasksToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = _allTasks
          .map((task) => json.encode(task.toMap()))
          .toList();
      await prefs.setStringList(_storageKey, tasksJson);
      print('TaskService: Saved ${_allTasks.length} tasks to storage');
    } catch (e) {
      print('TaskService: Error saving tasks to storage: $e');
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    print('TaskService: Adding task - ${task.title} for ${task.dueDate}');
    _allTasks.add(task);
    print('TaskService: Total tasks now: ${_allTasks.length}');
    await _saveTasksToStorage();
  }

  // Get all tasks
  List<Task> getAllTasks() {
    print('TaskService: Getting all tasks - ${_allTasks.length} tasks');
    return List.from(_allTasks);
  }

  // Get tasks for a specific date
  List<Task> getTasksForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final tasks = _allTasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
    print(
      'TaskService: Getting tasks for ${targetDate} - found ${tasks.length} tasks',
    );
    return tasks;
  }

  // Get today's tasks
  List<Task> getTodayTasks() {
    final today = DateTime.now();
    final tasks = getTasksForDate(today);
    print('TaskService: Today\'s tasks - ${tasks.length} tasks');
    return tasks;
  }

  // Update task completion status
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _allTasks[taskIndex];
      _allTasks[taskIndex] = task.copyWith(isCompleted: isCompleted);
      print(
        'TaskService: Updated task ${task.title} completion to $isCompleted',
      );
      await _saveTasksToStorage();
    }
  }

  // Update task start status
  Future<void> updateTaskStartStatus(String taskId, bool isStarted) async {
    final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _allTasks[taskIndex];
      _allTasks[taskIndex] = task.copyWith(isStarted: isStarted);
      print(
        'TaskService: Updated task ${task.title} start status to $isStarted',
      );
      await _saveTasksToStorage();
    }
  }

  // Update task (for editing)
  Future<void> updateTask(Task updatedTask) async {
    final taskIndex = _allTasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex != -1) {
      _allTasks[taskIndex] = updatedTask;
      print('TaskService: Updated task ${updatedTask.title}');
      await _saveTasksToStorage();
    }
  }

  // Remove a task
  Future<void> removeTask(String taskId) async {
    _allTasks.removeWhere((task) => task.id == taskId);
    await _saveTasksToStorage();
  }

  // Clear all tasks (for testing)
  Future<void> clearAllTasks() async {
    _allTasks.clear();
    await _saveTasksToStorage();
  }
}
