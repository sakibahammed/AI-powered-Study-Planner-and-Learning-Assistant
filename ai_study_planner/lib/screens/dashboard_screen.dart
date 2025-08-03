import 'package:flutter/material.dart';
import '../widgets/greeting_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/upcoming_section.dart';
import '../widgets/quick_action_section.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingSection(),
                const SizedBox(height: 20),
                StatCard(
                  title: "Your Average Score",
                  value: "68",
                  subtitle: "Quizzes taken: 12",
                  percentage: 0.68,
                  percentageText: "68.0%",
                ),
                const SizedBox(height: 16),
                StatCard(
                  title: "Today's Tasks",
                  value: "3",
                  subtitle: "out of 7",
                  percentage: 3 / 7,
                  percentageText: "42.9%",
                ),
                const SizedBox(height: 30),
                UpcomingSection(),
                const SizedBox(height: 30),
                QuickActionSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
