import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'flashcard_detail.dart';

class FlashcardPage extends StatelessWidget {
  final List<Flashcard> flashcards = [
    Flashcard(
      id: '1',
      subject: 'Programming',
      title: 'Fundamentals of Computer Science',
      content: [
        {'question': 'What is a variable?', 'answer': 'A container for data.'},
        {
          'question': 'What is a function?',
          'answer': 'Reusable block of code.',
        },
      ],
    ),
    Flashcard(
      id: '2',
      subject: 'English',
      title: 'The Life of Shakespeare',
      content: [
        {'question': 'Who is Shakespeare?', 'answer': 'A famous playwright.'},
      ],
    ),
    Flashcard(
      id: '3',
      subject: 'Math',
      title: 'Trigonometry',
      content: [
        {'question': 'What is sin(90°)?', 'answer': '1'},
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flashcards')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            final flashcard = flashcards[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(
                  flashcard.subject,
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(flashcard.title),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FlashcardDetailPage(flashcard: flashcard),
                          ),
                        );
                      },
                      child: Text("Read more"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
