class MCQQuestion {
  final String question;
  final List<String> options; // A,B,C,D
  final int correctIndex;
  int? selectedIndex;

  MCQQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.selectedIndex,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'selectedIndex': selectedIndex,
  };

  factory MCQQuestion.fromJson(Map<String, dynamic> json) => MCQQuestion(
    question: json['question'] as String,
    options: (json['options'] as List).map((e) => e.toString()).toList(),
    correctIndex: json['correctIndex'] as int,
    selectedIndex: json['selectedIndex'] as int?,
  );
}
