import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { high, medium, low }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime date;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.date,
    required this.isCompleted,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return Task(
      id: doc.id,
      title: (d['title'] ?? '').toString(),
      description: (d['description'] ?? '').toString(),
      priority: _priorityFromString((d['priority'] ?? 'medium').toString()),
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: (d['isCompleted'] ?? false) == true,
    );
  }

  static TaskPriority _priorityFromString(String s) {
    switch (s) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}
