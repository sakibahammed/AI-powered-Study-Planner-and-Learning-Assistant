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
      appBar: AppBar(
        title: Text('Flashcard'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Flashcards',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                            color: const Color.fromARGB(255, 181, 88, 23),
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
                                    builder: (context) => FlashcardDetailPage(
                                      flashcard: flashcard,
                                    ),
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
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to all flashcards screen
                    },
                    child: Text(
                      'See all flashcards',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Text(
                  'Generate your flashcard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your topic',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text('or'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle PDF upload
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 195, 104, 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Upload a PDF file',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
