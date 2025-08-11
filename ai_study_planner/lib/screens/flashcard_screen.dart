import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/flashcard.dart';
import 'flashcard_detail.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  Future<String> _ensureUid() async {
    final auth = FirebaseAuth.instance;
    User? u = auth.currentUser;
    if (u == null) {
      final cred = await auth.signInAnonymously();
      u = cred.user;
    }
    return u!.uid;
  }

  Stream<List<Flashcard>> _flashcardsStream() async* {
    final uid = await _ensureUid();
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('flashcards')
        .orderBy('createdAt', descending: true);

    yield* col.snapshots().map(
          (snap) => snap.docs.map((d) => Flashcard.fromFirestore(d)).toList(),
        );
  }

  Future<void> _addFlashcard() async {
    final uid = await _ensureUid();

    final subjectCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Flashcard'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Add first Q/A (optional)'),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qCtrl,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: aCtrl,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final subject = subjectCtrl.text.trim();
              final title = titleCtrl.text.trim();
              if (subject.isEmpty || title.isEmpty) return;

              final col = FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('flashcards');

              final doc = col.doc();
              final List<Map<String, dynamic>> initialContent = [];
              if (qCtrl.text.trim().isNotEmpty || aCtrl.text.trim().isNotEmpty) {
                initialContent.add({
                  'question': qCtrl.text.trim(),
                  'answer': aCtrl.text.trim(),
                });
              }

              await doc.set({
                'subject': subject,
                'title': title,
                'content': initialContent,
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Flashcard>>(
        stream: _flashcardsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator(minHeight: 2);
          }
          final items = snap.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Flashcards',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (items.isEmpty)
                      const Text('No flashcards yet. Tap + to create one.')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final flashcard = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              title: Text(
                                flashcard.subject,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 181, 88, 23),
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
                                          builder: (_) => FlashcardDetailPage(
                                            flashcardId: flashcard.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Read more"),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final uid = await _ensureUid();
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('flashcards')
                                      .doc(flashcard.id)
                                      .delete();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to "All flashcards" if you later add pagination/filter
                        },
                        child: const Text(
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    const Text('Generate your flashcard',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your topic (UI only)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('or'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Handle PDF upload if you plan to parse → then save to Firestore
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 195, 104, 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Upload a PDF file',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
