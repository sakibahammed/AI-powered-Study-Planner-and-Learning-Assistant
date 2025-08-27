<<<<<<< Updated upstream
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String apiBaseUrl =
    'https://substitute-sold-hungry-reforms.trycloudflare.com';

class ChatServices {
  Future<String?> uploadFile(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiBaseUrl/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(respStr);
      return json['summary']; // Return the summary string from API
    } else {
      return null;
    }
  }

  Future<String?> askQuestion(String query) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'mode': 'qa', 'count': 3}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['response'] ?? "AI gave no response.";
    } else {
      return "[AI Error: ${response.statusCode}]";
    }
  }

  Future<void> resetSession() async {
    await http.post(Uri.parse('$apiBaseUrl/reset'));
  }
}
=======
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String apiBaseUrl = 'https://stylish-kw-produces-funky.trycloudflare.com';

class ChatServices {
  Future<String?> uploadFile(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiBaseUrl/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(respStr);
      return json['summary']; // Return the summary string from API
    } else {
      return null;
    }
  }

  Future<String?> askQuestion(String query) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'mode': 'qa', 'count': 3}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['response'] ?? "AI gave no response.";
    } else {
      return "[AI Error: ${response.statusCode}]";
    }
  }

  Future<void> resetSession() async {
    await http.post(Uri.parse('$apiBaseUrl/reset'));
  }
}
>>>>>>> Stashed changes
