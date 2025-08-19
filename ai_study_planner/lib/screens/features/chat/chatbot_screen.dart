import 'package:flutter/material.dart';
import 'chat_page.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChatPage(
      receiverUserEmail: 'ai_bot@studyplanner.com',
      receiverUserID: 'ai_bot',
    );
  }
}
