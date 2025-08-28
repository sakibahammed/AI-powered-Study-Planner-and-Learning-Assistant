class Goal {
  final int dailyGoal;
  final int weeklyGoal;
  final DateTime lastUpdated;

  Goal({
    required this.dailyGoal,
    required this.weeklyGoal,
    required this.lastUpdated,
  });

  factory Goal.defaultGoal() {
    return Goal(dailyGoal: 5, weeklyGoal: 25, lastUpdated: DateTime.now());
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      dailyGoal: json['dailyGoal'] ?? 5,
      weeklyGoal: json['weeklyGoal'] ?? 25,
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyGoal': dailyGoal,
      'weeklyGoal': weeklyGoal,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Goal copyWith({int? dailyGoal, int? weeklyGoal, DateTime? lastUpdated}) {
    return Goal(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Get goal percentage for a given completion count
  double getDailyGoalPercentage(int completedTasks) {
    if (dailyGoal == 0) return 0.0;
    return (completedTasks / dailyGoal).clamp(0.0, 1.0);
  }

  double getWeeklyGoalPercentage(int completedTasks) {
    if (weeklyGoal == 0) return 0.0;
    return (completedTasks / weeklyGoal).clamp(0.0, 1.0);
  }

  // Get motivational message based on goal progress
  String getDailyGoalMessage(int completedTasks) {
    final percentage = getDailyGoalPercentage(completedTasks);

    if (percentage == 0.0) {
      return 'Start your day with a task!';
    } else if (percentage < 0.25) {
      return 'Great start! Keep going!';
    } else if (percentage < 0.5) {
      return 'You\'re making progress!';
    } else if (percentage < 0.75) {
      return 'Almost there!';
    } else if (percentage < 1.0) {
      return 'So close to your goal!';
    } else if (percentage == 1.0) {
      return 'Goal achieved! 🎉';
    } else {
      return 'Overachiever! 🌟';
    }
  }

  String getWeeklyGoalMessage(int completedTasks) {
    final percentage = getWeeklyGoalPercentage(completedTasks);

    if (percentage == 0.0) {
      return 'Set your weekly goal and start working!';
    } else if (percentage < 0.25) {
      return 'Week is just beginning!';
    } else if (percentage < 0.5) {
      return 'Halfway through the week!';
    } else if (percentage < 0.75) {
      return 'Great progress this week!';
    } else if (percentage < 1.0) {
      return 'Almost at your weekly goal!';
    } else if (percentage == 1.0) {
      return 'Weekly goal achieved! 🏆';
    } else {
      return 'Weekly overachiever! 🌟';
    }
  }
}
