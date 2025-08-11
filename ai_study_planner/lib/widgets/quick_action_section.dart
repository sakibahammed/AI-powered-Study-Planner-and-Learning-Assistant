import 'package:flutter/material.dart';
import '../screens/flashcard_screen.dart';
import '../screens/planner_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/chatbot_screen.dart';
import '../theme/app_colors.dart';

class QuickActionSection extends StatelessWidget {
  const QuickActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Action',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            actionItem(context, Icons.menu_book, 'Flashcard', FlashcardPage()),
            actionItem(
              context,
              Icons.calendar_today,
              'Planner',
              const PlannerScreen(),
            ),
            actionItem(context, Icons.quiz, 'Quiz', QuizScreen()),
            actionItem(
              context,
              Icons.chat_bubble,
              'Ask Studybot',
              const ChatbotScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget actionItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent,
            radius: 24,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
