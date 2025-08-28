class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final bool isStarted;
  final String category;
  final DateTime? startTime;
  final DateTime? completionTime;
  final Duration? completionDuration;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.isStarted = false,
    required this.category,
    this.startTime,
    this.completionTime,
    this.completionDuration,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isStarted,
    String? category,
    DateTime? startTime,
    DateTime? completionTime,
    Duration? completionDuration,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isStarted: isStarted ?? this.isStarted,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      completionDuration: completionDuration ?? this.completionDuration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isStarted': isStarted,
      'category': category,
      'startTime': startTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'completionDuration': completionDuration?.inMilliseconds,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] ?? false,
      isStarted: map['isStarted'] ?? false,
      category: map['category'],
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'])
          : null,
      completionTime: map['completionTime'] != null
          ? DateTime.parse(map['completionTime'])
          : null,
      completionDuration: map['completionDuration'] != null
          ? Duration(milliseconds: map['completionDuration'])
          : null,
    );
  }
}
