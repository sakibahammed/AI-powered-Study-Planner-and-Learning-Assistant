import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result.dart';

class QuizService {
  static QuizService? _instance;
  static QuizService get instance => _instance ??= QuizService._();
  QuizService._();

  static const String _storageKey = 'quiz_results_v1';
  List<QuizResult> _quizResults = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _quizResults = jsonList
            .map((json) => QuizResult.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      _isInitialized = true;
    } catch (e) {
      print('QuizService: Error initializing - $e');
      _quizResults = [];
      _isInitialized = true;
    }
  }

  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await initialize();
      _quizResults.add(result);

      // Keep only last 50 results
      if (_quizResults.length > 50) {
        _quizResults = _quizResults.sublist(_quizResults.length - 50);
      }

      await _saveToStorage();
    } catch (e) {
      print('QuizService: Error saving quiz result - $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        _quizResults.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('QuizService: Error saving to storage - $e');
    }
  }

  QuizResult? getLastQuizResult() {
    if (_quizResults.isEmpty) return null;
    return _quizResults.last;
  }

  List<QuizResult> getAllQuizResults() {
    return List.from(_quizResults.reversed); // Most recent first
  }

  List<QuizResult> getQuizResultsByTopic(String topic) {
    return _quizResults
        .where(
          (result) => result.topic.toLowerCase().contains(topic.toLowerCase()),
        )
        .toList();
  }

  double getAverageScore() {
    if (_quizResults.isEmpty) return 0.0;
    final total = _quizResults.fold(0, (sum, result) => sum + result.score);
    return total / _quizResults.length;
  }

  int getTotalQuizzesTaken() {
    return _quizResults.length;
  }

  void clearAllResults() {
    _quizResults.clear();
    _saveToStorage();
  }
}
