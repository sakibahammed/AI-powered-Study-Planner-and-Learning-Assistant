import 'dart:io';
import 'package:ai_study_planner/screens/features/quiz/mcq_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/mcq.dart';
import '../../../models/quiz_result.dart';
import '../../../services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Set your base URL (no trailing slash)
  static const String baseUrl =
      'https://stylish-kw-produces-funky.trycloudflare.com';

  final TextEditingController _topicController = TextEditingController();
  final _countController = TextEditingController(text: '5');

  late final McqService _svc = McqService(baseUrl);
  final QuizService _quizService = QuizService.instance;

  List<MCQQuestion> _questions = [];
  bool _loading = false;
  QuizResult? _lastQuizResult;

  @override
  void initState() {
    super.initState();
    _loadLastQuizResult();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _loadLastQuizResult() async {
    try {
      await _quizService.initialize();
      setState(() {
        _lastQuizResult = _quizService.getLastQuizResult();
      });
    } catch (e) {
      print('Error loading last quiz result: $e');
    }
  }

  void _showSnack(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _uploadPdf() async {
    try {
      setState(() => _loading = true);
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withReadStream: false,
      );
      if (picked == null || picked.files.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      final filePath = picked.files.single.path;
      if (filePath == null) {
        setState(() => _loading = false);
        _showSnack('No file path found.', color: Colors.red);
        return;
      }

      final status = await _svc.uploadMcqPdf(File(filePath));
      _showSnack(status);
    } catch (e) {
      _showSnack('Upload error: $e', color: Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _startQuiz() async {
    try {
      setState(() {
        _loading = true;
      });

      final cnt = int.tryParse(_countController.text.trim());
      final count = (cnt != null && cnt > 0 && cnt <= 50) ? cnt : 5;

      final raw = await _svc.generateMcqsRaw(count: count);
      final parsed = _svc.parseMcqText(raw);

      if (parsed.isEmpty) {
        _showSnack('No MCQs parsed from response.', color: Colors.red);
        setState(() => _questions = []);
        return;
      }

      setState(() {
        _questions = parsed;
      });
      _showSnack('Loaded ${_questions.length} MCQs. Good luck!');
    } catch (e) {
      _showSnack('Quiz generation error: $e', color: Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _submitQuiz() {
    if (_questions.isEmpty) return;

    int correct = 0;
    for (final q in _questions) {
      if (q.selectedIndex != null && q.selectedIndex == q.correctIndex) {
        correct++;
      }
    }

    final percent = (_questions.isEmpty)
        ? 0
        : ((correct / _questions.length) * 100).round();

    // Save quiz result
    final quizResult = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: percent,
      totalQuestions: _questions.length,
      date: DateTime.now(),
      topic: _topicController.text.trim().isEmpty
          ? 'General Quiz'
          : _topicController.text.trim(),
      questions: List.from(_questions),
    );

    _quizService.saveQuizResult(quizResult);

    setState(() {
      _lastQuizResult = quizResult;
    });

    _showSnack('You scored $percent%! ${_getScoreMessage(percent)}');
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Excellent! 🎉';
    if (score >= 80) return 'Great job! 👍';
    if (score >= 70) return 'Good work! 👏';
    if (score >= 60) return 'Not bad! 💪';
    return 'Keep practicing! 📚';
  }

  void _resetQuiz() {
    setState(() {
      for (final q in _questions) {
        q.selectedIndex = null;
      }
    });
    _showSnack('Quiz reset! Try again! 🔄');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EAD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EAD8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Quiz Card
                  _buildLastQuizCard(),
                  const SizedBox(height: 20),

                  // Take new quiz
                  const Text(
                    'Take a new quiz?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildParameterRow(
                    'Total Time',
                    Row(
                      children: const [
                        Text(
                          '20 mins',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Colors.black),
                      ],
                    ),
                  ),
                  _buildParameterRow(
                    'Total MCQs',
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _countController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Topic input
                  TextField(
                    controller: _topicController,
                    decoration: InputDecoration(
                      hintText: 'Enter your topic (optional label)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Upload PDF button
                  Center(
                    child: SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _uploadPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text(
                          'Upload a PDF file',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Start Quiz button
                  Center(
                    child: SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _startQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text(
                          'Start Quiz',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quiz list
                  if (_questions.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    for (int i = 0; i < _questions.length; i++)
                      _buildQuestionCard(_questions[i], i),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _submitQuiz,
                            icon: const Icon(Icons.check),
                            label: const Text('Submit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _resetQuiz,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.pink),
                              foregroundColor: Colors.pink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),

            if (_loading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastQuizCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Last Quiz',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Score',
            style: TextStyle(
              color: Colors.pink[400],
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lastQuizResult?.topic ?? 'No quiz taken yet',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_lastQuizResult != null)
                    Text(
                      DateFormat('MMM dd, yyyy').format(_lastQuizResult!.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (_lastQuizResult?.score ?? 0) >= 60
                        ? Colors.green
                        : Colors.orange,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    _lastQuizResult?.score.toString() ?? '--',
                    style: TextStyle(
                      color: (_lastQuizResult?.score ?? 0) >= 60
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String title, Widget trailing) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildQuestionCard(MCQQuestion q, int idx) {
    final bool isSubmitted =
        _lastQuizResult != null &&
        _lastQuizResult!.questions.length > idx &&
        _lastQuizResult!.questions[idx].selectedIndex != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${idx + 1}. ${q.question}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < q.options.length; i++) ...[
            RadioListTile<int>(
              title: Text(
                '${String.fromCharCode(65 + i)}. ${q.options[i]}',
                style: const TextStyle(fontSize: 14),
              ),
              value: i,
              groupValue: q.selectedIndex,
              onChanged: isSubmitted
                  ? null
                  : (val) {
                      setState(() => q.selectedIndex = val);
                    },
              activeColor: Colors.pink,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
          if (isSubmitted) ...[
            const SizedBox(height: 4),
            Text(
              q.selectedIndex == q.correctIndex
                  ? '✅ Correct'
                  : '❌ Answer: ${String.fromCharCode(65 + q.correctIndex)}',
              style: TextStyle(
                color: q.selectedIndex == q.correctIndex
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
