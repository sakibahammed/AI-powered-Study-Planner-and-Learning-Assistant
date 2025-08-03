import 'package:flutter/material.dart';
import '../models/upcoming_task.dart';

class UpcomingSection extends StatelessWidget {
  final List<UpcomingTask> tasks = [
    UpcomingTask(title: "Math Assignment", due: "Due Tomorrow"),
    UpcomingTask(title: "English Test", due: "Due on 10 Jul"),
    UpcomingTask(title: "Physics Test", due: "Due on 20 Jul"),
    UpcomingTask(title: "English Assignment", due: "Due on 2 Aug"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...tasks.map(
          (task) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              task.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(task.due),
          ),
        ),
      ],
    );
  }
}
