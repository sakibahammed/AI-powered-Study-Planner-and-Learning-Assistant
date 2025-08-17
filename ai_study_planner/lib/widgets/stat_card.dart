import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/task.dart';
import 'today_tasks_modal.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double percentage;
  final String percentageText;
  final List<Task>? tasks; // Optional tasks for Today's Tasks card
  final Function(String taskId, bool isCompleted)?
  onTaskCompleted; // Callback for task completion
  final Function(String taskId, bool isStarted)?
  onTaskStarted; // Callback for task start

  const StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.percentage,
    required this.percentageText,
    this.tasks,
    this.onTaskCompleted,
    this.onTaskStarted,
  });

  void _showTasksModal(BuildContext context) {
    if (tasks != null && onTaskCompleted != null) {
      showDialog(
        context: context,
        builder: (context) => TodayTasksModal(
          tasks: tasks!,
          onTaskCompleted: onTaskCompleted!,
          onTaskStarted: onTaskStarted,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: title == "Today's Tasks" ? () => _showTasksModal(context) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: AppColors.statText, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.statText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.statSubText),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(
                    value: percentage,
                    color: Colors.yellow,
                    backgroundColor: Colors.white30,
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  percentageText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
