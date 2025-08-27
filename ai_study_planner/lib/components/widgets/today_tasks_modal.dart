import 'package:flutter/material.dart';
import '../../models/task.dart';

class TodayTasksModal extends StatefulWidget {
  final List<Task> tasks;
  final Function(String taskId, bool isCompleted) onTaskCompleted;
  final Function(String taskId, bool isStarted)? onTaskStarted;

  const TodayTasksModal({
    super.key,
    required this.tasks,
    required this.onTaskCompleted,
    this.onTaskStarted,
  });

  @override
  TodayTasksModalState createState() => TodayTasksModalState();
}

class TodayTasksModalState extends State<TodayTasksModal> {
  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    tasks = List.from(widget.tasks);
  }

  void _startTask(String taskId) async {
    setState(() {
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = tasks[taskIndex];
        tasks[taskIndex] = task.copyWith(isStarted: true);
        // Call the start callback if provided, otherwise use completion callback
        if (widget.onTaskStarted != null) {
          widget.onTaskStarted!(taskId, true);
        } else {
          // Fallback to completion callback for backward compatibility
          widget.onTaskCompleted(taskId, false);
        }
      }
    });
  }

  void _completeTask(String taskId) async {
    setState(() {
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = tasks[taskIndex];
        tasks[taskIndex] = task.copyWith(isCompleted: true);
        widget.onTaskCompleted(taskId, true);
      }
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return Colors.blue;
      case 'work':
        return Colors.green;
      case 'personal':
        return Colors.purple;
      case 'health':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.task;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Simple Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.today, color: Colors.pink[400], size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Today\'s Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Task count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${tasks.where((task) => !task.isCompleted).length} remaining',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Spacer(),
                  Text(
                    '${tasks.where((task) => task.isCompleted).length} completed',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            // Tasks list
            Expanded(
              child: tasks.isEmpty ? _buildEmptyState() : _buildTasksList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration, size: 64, color: Colors.orange[400]),
          SizedBox(height: 16),
          Text(
            'Yee! No tasks for today!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Time to relax and enjoy your day',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🎉 You\'re all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: task.isCompleted
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[100]!, Colors.grey[200]!],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: task.isCompleted
                  ? Colors.grey[300]!
                  : _getCategoryColor(task.category).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: task.isCompleted
                    ? Colors.grey.withValues(alpha: 0.1)
                    : _getCategoryColor(task.category).withValues(alpha: 0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? Colors.grey[300]
                        : _getCategoryColor(
                            task.category,
                          ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _getCategoryIcon(task.category),
                    color: task.isCompleted
                        ? Colors.grey[600]
                        : _getCategoryColor(task.category),
                    size: 20,
                  ),
                ),

                SizedBox(width: 16),

                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? Colors.grey[600]
                                  : Colors.black87,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // In Progress badge
                          if (task.isStarted && !task.isCompleted)
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.orange[400]!,
                                    Colors.red[400]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_circle,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'In Progress',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: task.isCompleted
                              ? Colors.grey[500]
                              : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: task.isCompleted
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[400]!,
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getCategoryColor(
                                      task.category,
                                    ).withValues(alpha: 0.8),
                                    _getCategoryColor(
                                      task.category,
                                    ).withValues(alpha: 0.6),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: task.isCompleted
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : _getCategoryColor(
                                      task.category,
                                    ).withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          task.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: task.isCompleted
                                ? Colors.grey[700]
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16),

                // Action button
                _buildActionButton(task),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(Task task) {
    // Task is completed - show disabled button
    if (task.isCompleted) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[400]!, Colors.grey[500]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Task is started but not completed - show Complete button
    if (task.isStarted) {
      return GestureDetector(
        onTap: () => _completeTask(task.id),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green[400]!, Colors.green[500]!],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Task is not started - show Start button
    return GestureDetector(
      onTap: () => _startTask(task.id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink[400]!, Colors.purple[400]!],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'Start',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
