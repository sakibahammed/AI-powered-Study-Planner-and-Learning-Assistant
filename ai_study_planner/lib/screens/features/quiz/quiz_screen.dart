import 'dart:io';
import 'package:ai_study_planner/screens/features/quiz/mcq_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../models/mcq.dart';

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

  List<MCQQuestion> _questions = [];
  bool _loading = false;
  int? _score; // last submitted score

  @override
  void dispose() {
    _topicController.dispose();
    _countController.dispose();
    super.dispose();
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
        _score = null;
      });

      final cnt = int.tryParse(_countController.text.trim());
      final count = (cnt != null && cnt > 0 && cnt <= 50) ? cnt : 5;

      final raw = await _svc.generateMcqsRaw(count: count);
      // debugPrint('MCQ raw (first 400): ${raw.substring(0, raw.length.clamp(0, 400))}');
      final parsed = _svc.parseMcqText(raw);

      if (parsed.isEmpty) {
        _showSnack('No MCQs parsed from response.', color: Colors.red);
        setState(() => _questions = []);
        return;
      }

      setState(() {
        _questions = parsed;
      });
    } catch (e) {
      _showSnack('Quiz generation error: $e', color: Colors.red);
    } finally {
      setState(() => _loading = false);
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildParameterRow('Total Time', '20 mins'),
              _buildParameterRow('Total Marks', '15'),
              const SizedBox(height: 16),

              // Topic input
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  hintText: 'Enter your topic',
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
                child: Text('or', style: TextStyle(color: Colors.grey[600])),
              ),
              const SizedBox(height: 10),

              // Upload PDF button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _uploadPdf,
                  icon: Icon(
                    _loading ? Icons.hourglass_empty : Icons.upload_file,
                  ),
                  label: Text(_loading ? 'Uploading...' : 'Upload PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Start Quiz button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _startQuiz,
                  icon: Icon(
                    _loading ? Icons.hourglass_empty : Icons.play_arrow,
                  ),
                  label: Text(_loading ? 'Generating...' : 'Start Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              if (_questions.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Generated Questions:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._questions.map((q) => _buildQuestionCard(q)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastQuizCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Quiz Result',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildParameterRow('Score', _score?.toString() ?? 'N/A'),
          _buildParameterRow('Questions', _questions.length.toString()),
          _buildParameterRow('Date', DateTime.now().toString().split(' ')[0]),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(MCQQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...question.options.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Radio<int>(
                    value: entry.key,
                    groupValue: question.selectedIndex,
                    onChanged: (value) {
                      setState(() {
                        question.selectedIndex = value;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      '${String.fromCharCode(65 + entry.key)}. ${entry.value}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
