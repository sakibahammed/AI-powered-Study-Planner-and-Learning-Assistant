<<<<<<< Updated upstream
class Flashcard {
  final String id;
  final String subject;
  final String title;
  final List<Map<String, String>> content;

  Flashcard({
    required this.id,
    required this.subject,
    required this.title,
    required this.content,
  });
}
=======
class Flashcard {
  final String id;
  final String subject;
  final String title;

  /// List of maps: [{'question': 'Q1', 'answer': 'A1'}, ...]
  final List<Map<String, String>> content;

  Flashcard({
    required this.id,
    required this.subject,
    required this.title,
    required this.content,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    final rawContent = (json['content'] as List? ?? [])
        .map(
          (e) => Map<String, String>.from(
            (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
          ),
        )
        .toList();

    return Flashcard(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: rawContent,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'title': title,
    'content': content
        .map(
          (e) => {'question': e['question'] ?? '', 'answer': e['answer'] ?? ''},
        )
        .toList(),
  };
}
>>>>>>> Stashed changes
