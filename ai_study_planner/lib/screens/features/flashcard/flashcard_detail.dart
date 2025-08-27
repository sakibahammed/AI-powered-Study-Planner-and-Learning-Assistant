import 'package:ai_study_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../models/flashcard.dart';

class FlashcardDetailPage extends StatelessWidget {
  final Flashcard flashcard;

  const FlashcardDetailPage({super.key, required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Flashcard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: flashcard.content.length,
          itemBuilder: (context, index) {
            final qa = flashcard.content[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text("Q: ${qa['question']}"),
                subtitle: Text("A: ${qa['answer']}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
