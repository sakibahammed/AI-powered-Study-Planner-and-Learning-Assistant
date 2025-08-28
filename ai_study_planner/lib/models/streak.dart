class Streak {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastCompletedDate;
  final List<DateTime> completedDates;

  Streak({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCompletedDate,
    required this.completedDates,
  });

  factory Streak.initial() {
    return Streak(
      currentStreak: 0,
      longestStreak: 0,
      lastCompletedDate: DateTime.now().subtract(Duration(days: 1)),
      completedDates: [],
    );
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastCompletedDate: DateTime.parse(
        json['lastCompletedDate'] ?? DateTime.now().toIso8601String(),
      ),
      completedDates:
          (json['completedDates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate.toIso8601String(),
      'completedDates': completedDates
          .map((date) => date.toIso8601String())
          .toList(),
    };
  }

  // Check if a date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if a date is yesterday
  bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Check if a date is consecutive to the last completed date
  bool isConsecutive(DateTime date) {
    if (completedDates.isEmpty) return true;

    final lastDate = completedDates.last;
    final difference = date.difference(lastDate).inDays;
    return difference == 1;
  }

  // Get streak message based on current streak
  String getStreakMessage() {
    if (currentStreak == 0) {
      return 'Start your streak today!';
    } else if (currentStreak == 1) {
      return 'Great start! Keep going!';
    } else if (currentStreak < 5) {
      return 'You\'re building momentum!';
    } else if (currentStreak < 10) {
      return 'Impressive dedication!';
    } else if (currentStreak < 20) {
      return 'You\'re on fire! 🔥';
    } else if (currentStreak < 50) {
      return 'Unstoppable! 💪';
    } else {
      return 'Legendary! You\'re unstoppable! 🏆';
    }
  }

  // Get streak emoji based on current streak
  String getStreakEmoji() {
    if (currentStreak == 0) return '💪';
    if (currentStreak < 3) return '🔥';
    if (currentStreak < 7) return '🔥🔥';
    if (currentStreak < 14) return '🔥🔥🔥';
    if (currentStreak < 30) return '🔥🔥🔥🔥';
    return '🔥🔥🔥🔥🔥';
  }
}
