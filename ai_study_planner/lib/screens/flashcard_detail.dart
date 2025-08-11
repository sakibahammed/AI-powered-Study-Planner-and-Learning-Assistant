import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/flashcard.dart';

class FlashcardDetailPage extends StatelessWidget {
  final String flashcardId;

  const FlashcardDetailPage({super.key, required this.flashcardId});

  Future<String> _ensureUid() async {
    final auth = FirebaseAuth.instance;
    User? u = auth.currentUser;
    if (u == null) {
      final cred = await auth.signInAnonymously();
      u = cred.user;
    }
    return u!.uid;
  }

  Stream<Flashcard?> _flashcardStream() async* {
    final uid = await _ensureUid();
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('flashcards')
        .doc(flashcardId);

    yield* ref.snapshots().map((doc) {
      if (!doc.exists) return null;
      return Flashcard.fromFirestore(doc);
    });
  }

  Future<void> _addQA(BuildContext context) async {
    final uid = await _ensureUid();

    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Q/A'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qCtrl,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: aCtrl,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final q = qCtrl.text.trim();
              final a = aCtrl.text.trim();
              if (q.isEmpty && a.isEmpty) return;

              final ref = FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('flashcards')
                  .doc(flashcardId);

              // Append to array field `content`
              await ref.update({
                'content': FieldValue.arrayUnion([
                  {'question': q, 'answer': a}
                ])
              });

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Flashcard?>(
      stream: _flashcardStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final flashcard = snap.data;
        if (flashcard == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Flashcard not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(flashcard.title),
            actions: [
              IconButton(
                onPressed: () => _addQA(context),
                icon: const Icon(Icons.add),
                tooltip: 'Add Q/A',
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
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text("Q: ${qa.question}"),
                    subtitle: Text("A: ${qa.answer}"),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
