import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardDetailPage extends StatelessWidget {
  final Flashcard flashcard;

  FlashcardDetailPage({required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(flashcard.title)),
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
