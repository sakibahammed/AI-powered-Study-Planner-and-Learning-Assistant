import 'mcq.dart';

class QuizResult {
  final String id;
  final int score;
  final int totalQuestions;
  final DateTime date;
  final String topic;
  final List<MCQQuestion> questions;

  QuizResult({
    required this.id,
    required this.score,
    required this.totalQuestions,
    required this.date,
    required this.topic,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'score': score,
    'totalQuestions': totalQuestions,
    'date': date.toIso8601String(),
    'topic': topic,
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    id: json['id'] as String,
    score: json['score'] as int,
    totalQuestions: json['totalQuestions'] as int,
    date: DateTime.parse(json['date'] as String),
    topic: json['topic'] as String,
    questions: (json['questions'] as List)
        .map((q) => MCQQuestion.fromJson(q as Map<String, dynamic>))
        .toList(),
  );
}
