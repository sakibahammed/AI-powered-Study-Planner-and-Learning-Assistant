import 'package:cloud_firestore/cloud_firestore.dart';

class QA {
  final String question;
  final String answer;

  QA({required this.question, required this.answer});

  Map<String, dynamic> toMap() => {
        'question': question,
        'answer': answer,
      };

  factory QA.fromMap(Map<String, dynamic> m) => QA(
        question: (m['question'] ?? '').toString(),
        answer: (m['answer'] ?? '').toString(),
      );
}

class Flashcard {
  final String id;
  final String subject;
  final String title;
  final List<QA> content;
  final DateTime? createdAt;

  Flashcard({
    required this.id,
    required this.subject,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'subject': subject,
        'title': title,
        'content': content.map((q) => q.toMap()).toList(),
        'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      };

  factory Flashcard.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    final raw = (d['content'] as List?) ?? [];
    return Flashcard(
      id: doc.id,
      subject: (d['subject'] ?? '').toString(),
      title: (d['title'] ?? '').toString(),
      content: raw
          .whereType<Map<String, dynamic>>()
          .map((m) => QA.fromMap(m))
          .toList(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
