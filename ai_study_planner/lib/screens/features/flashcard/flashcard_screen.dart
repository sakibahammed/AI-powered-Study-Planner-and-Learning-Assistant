import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/flashcard.dart';
import 'flashcard_detail.dart';
import 'flashcard_service.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  // Set your base URL (no trailing slash)
  static const String baseUrl =
      'https://stylish-kw-produces-funky.trycloudflare.com';

  static const String _storageKey = 'flashcards_storage_v1';

  late final FlashcardService svc = FlashcardService(baseUrl);
  final TextEditingController _topicCtrl = TextEditingController();
  final List<Flashcard> flashcards = []; // initially empty

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFromLocal();
  }

  String _preview(String s, [int max = 400]) {
    if (s.isEmpty) return s;
    return s.substring(0, s.length > max ? max : s.length);
  }

  Future<void> _uploadAndGenerate() async {
    try {
      setState(() => _loading = true);

      // 1) Pick a PDF
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
        _showSnack('No file path found.');
        return;
      }
      final pdf = File(filePath);

      // 2) Upload
      final status = await svc.uploadPdf(pdf);
      _showSnack(status.isNotEmpty ? status : 'PDF uploaded.');

      // 3) Generate flashcards (POST {"count": 5})
      final raw = await svc.generateRaw(count: 5);
      debugPrint('flashcards raw (first 400): ${_preview(raw, 400)}');

      // 4) Parse Q/A
      final qa = svc.parseQA(raw);
      if (qa.isEmpty) {
        _showSnack('No flashcards parsed from response.');
        setState(() => _loading = false);
        return;
      }

      // 5) Build a single set and REPLACE current list
      final filename = picked.files.single.name;
      final topic = _topicCtrl.text.trim();
      final newCard = Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subject: topic.isNotEmpty ? topic : 'PDF',
        title: topic.isNotEmpty
            ? 'Flashcards: $topic'
            : 'Flashcards from $filename',
        content: qa,
      );

      setState(() {
        flashcards.clear();
        flashcards.add(newCard);
      });

      // 6) Save to local storage
      await _saveToLocal();

      _showSnack('Generated ${qa.length} flashcards!');
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(_storageKey);
      if (encoded != null) {
        final decoded = jsonDecode(encoded) as List;
        setState(() {
          flashcards.clear();
          flashcards.addAll(
            decoded.map(
              (e) => Flashcard.fromJson(Map<String, dynamic>.from(e)),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Load error: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(flashcards.map((f) => f.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Save error: $e');
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
          'Flashcards',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic input
            TextField(
              controller: _topicCtrl,
              decoration: InputDecoration(
                hintText: 'Enter topic (optional)',
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
            const SizedBox(height: 16),

            // Upload and generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _uploadAndGenerate,
                icon: Icon(
                  _loading ? Icons.hourglass_empty : Icons.upload_file,
                ),
                label: Text(
                  _loading ? 'Processing...' : 'Upload PDF & Generate',
                ),
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

            if (flashcards.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Your Flashcards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ...flashcards.map((flashcard) => _buildFlashcardCard(flashcard)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardCard(Flashcard flashcard) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          flashcard.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Subject: ${flashcard.subject}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${flashcard.content.length} questions',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardDetailPage(flashcard: flashcard),
            ),
          );
        },
      ),
    );
  }
}
