import 'package:flutter/material.dart';
import '../screens/flashcard_screen.dart';
import '../screens/planner_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/chatbot_screen.dart';
import '../theme/app_colors.dart';

class QuickActionSection extends StatelessWidget {
  final VoidCallback? onPlannerReturn;
  final Function(DateTime)? onDateSelected;

  const QuickActionSection({
    Key? key,
    this.onPlannerReturn,
    this.onDateSelected,
  }) : super(key: key);

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
              PlannerScreen(onDateSelected: onDateSelected),
              onReturn: onPlannerReturn,
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
    Widget screen, {
    VoidCallback? onReturn,
  }) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
        // Call the callback when returning from the screen
        if (onReturn != null) {
          onReturn();
        }
      },
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
