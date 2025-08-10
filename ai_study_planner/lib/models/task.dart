class Task {
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime date;
  bool isCompleted;

  Task(
    this.title,
    this.description,
    this.priority,
    this.date, {
    this.isCompleted = false,
  });
}

enum TaskPriority { high, medium, low }
