<<<<<<< Updated upstream
import 'package:flutter/material.dart';
import '../../../models/flashcard.dart';
import 'flashcard_detail.dart';

class FlashcardPage extends StatelessWidget {
  final List<Flashcard> flashcards = [
    Flashcard(
      id: '1',
      subject: 'Programming',
      title: 'Fundamentals of Computer Science',
      content: [
        {'question': 'What is a variable?', 'answer': 'A container for data.'},
        {
          'question': 'What is a function?',
          'answer': 'Reusable block of code.',
        },
      ],
    ),
    Flashcard(
      id: '2',
      subject: 'English',
      title: 'The Life of Shakespeare',
      content: [
        {'question': 'Who is Shakespeare?', 'answer': 'A famous playwright.'},
      ],
    ),
    Flashcard(
      id: '3',
      subject: 'Math',
      title: 'Trigonometry',
      content: [
        {'question': 'What is sin(90°)?', 'answer': '1'},
      ],
    ),
  ];

  FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6EAD8), // Light cream background
      appBar: AppBar(
        backgroundColor: Color(0xFFF6EAD8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Flashcard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your Flashcards Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Flashcards',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) {
                      final flashcard = flashcards[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flashcard.subject,
                                style: TextStyle(
                                  color: Colors.pink, // Reddish-pink color
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                flashcard.title,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FlashcardDetailPage(
                                        flashcard: flashcard,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Read more',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to all flashcards screen
                      },
                      child: Text(
                        'See all flashcards',
                        style: TextStyle(
                          color: Colors.grey[600],
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Generate Flashcard Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate your flashcard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your topic',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle PDF upload
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink, // Reddish-pink color
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Upload a PDF file',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
=======
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
        flashcards
          ..clear()
          ..add(newCard);
        _loading = false;
      });

      // 6) Persist locally
      await _saveToLocal();

      // Optional: open details automatically
      // if (!mounted) return;
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (_) => FlashcardDetailPage(flashcard: newCard)),
      // );
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Error: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(flashcards.map((f) => f.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
      debugPrint('Saved ${flashcards.length} flashcard set(s) locally.');
    } catch (e) {
      debugPrint('Local save error: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_storageKey);
      if (s == null || s.isEmpty) return;
      final List list = jsonDecode(s) as List;
      final loaded = list
          .map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      setState(() {
        flashcards
          ..clear()
          ..addAll(loaded.cast<Flashcard>());
      });
      debugPrint('Loaded ${flashcards.length} flashcard set(s) from local.');
    } catch (e) {
      debugPrint('Local load error: $e');
    }
  }

  Future<void> _clearLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      setState(() => flashcards.clear());
      _showSnack('Local flashcards cleared.');
    } catch (e) {
      debugPrint('Local clear error: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EAD8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Flashcard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear local',
            onPressed: _loading ? null : _clearLocal,
            icon: const Icon(Icons.delete_forever, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your Flashcards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Flashcards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (flashcards.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.style,
                                color: Colors.pink[300],
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No flashcards yet.\nUpload a PDF to generate.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: flashcards.length,
                          itemBuilder: (context, index) {
                            final flashcard = flashcards[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      flashcard.subject,
                                      style: const TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      flashcard.title,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FlashcardDetailPage(
                                                  flashcard: flashcard,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Read more',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              /* TODO: navigate to all flashcards */
                            },
                            child: Text(
                              'See all flashcards',
                              style: TextStyle(
                                color: Colors.grey[600],
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Generate Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate your flashcard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _topicCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter your topic (optional label)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _uploadAndGenerate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Upload a PDF file',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
>>>>>>> Stashed changes
