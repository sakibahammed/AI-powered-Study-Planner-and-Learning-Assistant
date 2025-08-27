import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FlashcardService {
  FlashcardService(this.baseUrl);
  final String baseUrl;

  Future<String> uploadPdf(File pdf) async {
    final uri = Uri.parse('$baseUrl/upload-flashcards');
    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', pdf.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return (data['status'] ?? '').toString();
    } else {
      throw Exception('Upload failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<String> generateRaw({int count = 5}) async {
    final uri = Uri.parse('$baseUrl/flashcards');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'count': count}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return (data['flashcards'] ?? '').toString();
    } else {
      throw Exception('Generate failed: ${res.statusCode} ${res.body}');
    }
  }

  List<Map<String, String>> parseQA(String raw) {
    if (raw.isEmpty) return const [];
    String text = raw.replaceAll('\r\n', '\n').trim();
    text = text.replaceFirst(
      RegExp(r'^Here are .*?flashcards.*?:\s*\n+', caseSensitive: false),
      '',
    );

    final results = <Map<String, String>>[];

    final qaRegex = RegExp(
      r'(?:^|\n)\s*(?:[-*]|\d+[.\)])?\s*\*{0,2}Q\*{0,2}\s*[:\-–]\s*(.*?)\s*\n\s*'
      r'(?:[-*]|\d+[.\)])?\s*\*{0,2}A\*{0,2}\s*[:\-–]\s*(.*?)(?='
      r'\n\s*(?:[-*]|\d+[.\)])?\s*\*{0,2}Q\*{0,2}\s*[:\-–]|\n{2,}|$)',
      dotAll: true,
      multiLine: true,
    );

    for (final m in qaRegex.allMatches(text)) {
      var q = (m.group(1) ?? '').trim();
      var a = (m.group(2) ?? '').trim();
      a = a.replaceAll(
        RegExp(r'[\(\[]\s*Page\s*\d+\s*[\)\]]\s*$', caseSensitive: false),
        '',
      ).trim();
      if (q.isNotEmpty && a.isNotEmpty) {
        results.add({'question': q, 'answer': a});
      }
    }

    if (results.isEmpty) {
      try {
        final dynamic maybeJson = jsonDecode(text);
        if (maybeJson is List) {
          for (final item in maybeJson) {
            final q = (item['question'] ?? '').toString().trim();
            final a = (item['answer'] ?? '').toString().trim();
            if (q.isNotEmpty && a.isNotEmpty) {
              results.add({'question': q, 'answer': a});
            }
          }
        } else if (maybeJson is Map &&
            maybeJson.containsKey('flashcards') &&
            maybeJson['flashcards'] is List) {
          for (final item in (maybeJson['flashcards'] as List)) {
            final q = (item['question'] ?? '').toString().trim();
            final a = (item['answer'] ?? '').toString().trim();
            if (q.isNotEmpty && a.isNotEmpty) {
              results.add({'question': q, 'answer': a});
            }
          }
        }
      } catch (_) {}
    }

    return results;
  }
}
