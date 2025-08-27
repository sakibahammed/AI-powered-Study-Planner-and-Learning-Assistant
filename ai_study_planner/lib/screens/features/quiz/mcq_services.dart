import 'dart:convert';
import 'dart:io';
import 'package:ai_study_planner/models/mcq.dart';
import 'package:http/http.dart' as http;

class McqService {
  McqService(this.baseUrl);
  final String baseUrl;

  /// Upload a PDF for MCQ extraction
  Future<String> uploadMcqPdf(File pdf) async {
    final uri = Uri.parse('$baseUrl/upload-mcq');
    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', pdf.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return (data['status'] ?? '').toString();
    } else {
      throw Exception('Upload MCQ failed: ${res.statusCode} ${res.body}');
    }
  }

  /// Generate MCQs from server with body: {"count": n}
  /// Update the path if your endpoint differs (e.g., /generate-mcq).
  Future<String> generateMcqsRaw({int count = 5}) async {
    final uri = Uri.parse('$baseUrl/mcq'); // <-- change if your route differs
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'count': count}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return (data['mcqs'] ?? '').toString();
    } else {
      throw Exception('Generate MCQ failed: ${res.statusCode} ${res.body}');
    }
  }

  /// Parse server "mcqs" text -> List<MCQQuestion>
  ///
  /// Expected format for each block:
  /// Q: question
  /// A. option
  /// B. option
  /// C. option
  /// D. option
  /// Answer: Letter.maybe text
  List<MCQQuestion> parseMcqText(String raw) {
    if (raw.isEmpty) return [];

    final text = raw.replaceAll('\r\n', '\n').trim();

    // Split by "Q:" occurrences
    final parts = text.split(RegExp(r'\n?Q:\s*', caseSensitive: false));
    final questions = <MCQQuestion>[];

    for (final part in parts) {
      final chunk = part.trim();
      if (chunk.isEmpty) continue;

      // Extract question (until first option line)
      final qMatch = RegExp(
        r'^(.*?)(?:\nA\.\s*|$)',
        dotAll: true,
        caseSensitive: false,
      ).firstMatch(chunk);
      if (qMatch == null) continue;
      final question = qMatch.group(1)!.trim();
      if (question.isEmpty) continue;

      // Extract options A-D
      String optA = _extractOption(chunk, 'A');
      String optB = _extractOption(chunk, 'B');
      String optC = _extractOption(chunk, 'C');
      String optD = _extractOption(chunk, 'D');

      final options = [optA, optB, optC, optD].map((e) => e.trim()).toList();

      // Extract answer letter
      final ansMatch = RegExp(
        r'Answer:\s*([A-Da-d])',
        caseSensitive: false,
      ).firstMatch(chunk);
      int correctIndex = 0; // default to A if missing
      if (ansMatch != null) {
        final letter = ansMatch.group(1)!.toUpperCase();
        correctIndex = {'A': 0, 'B': 1, 'C': 2, 'D': 3}[letter] ?? 0;
      }

      // Safety: ensure we have 4 options; if missing, pad with empty
      while (options.length < 4) options.add('');

      questions.add(
        MCQQuestion(
          question: question,
          options: options.sublist(0, 4),
          correctIndex: correctIndex,
        ),
      );
    }

    return questions;
  }

  String _extractOption(String chunk, String letter) {
    // Find "X. <text>" up to next letter or "Answer:"
    final regex = RegExp(
      '$letter\\.\\s*(.*?)(?=\\n[A-D]\\.\\s|\\nAnswer:|\\n\\Z)',
      dotAll: true,
      caseSensitive: false,
    );
    final m = regex.firstMatch(chunk);
    return (m?.group(1) ?? '').trim();
  }
}
