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
