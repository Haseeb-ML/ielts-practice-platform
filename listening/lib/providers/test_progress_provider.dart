import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TestProgressProvider extends ChangeNotifier {
  // Store completed tests by their IDs
  Set<String> _completedTests = {};
  
  // Store the user's answers for review later
  Map<String, Map<int, String>> _testAnswers = {};

  Set<String> get completedTests => _completedTests;

  TestProgressProvider() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load completed tests
    final List<String>? savedTests = prefs.getStringList('completed_tests');
    if (savedTests != null) {
      _completedTests = savedTests.toSet();
    }
    
    // Load answers
    final String? savedAnswersJson = prefs.getString('test_answers');
    if (savedAnswersJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(savedAnswersJson);
      _testAnswers = decoded.map((testId, dynamic answers) {
        final Map<int, String> parsedAnswers = (answers as Map<String, dynamic>).map(
          (key, value) => MapEntry(int.parse(key), value as String),
        );
        return MapEntry(testId, parsedAnswers);
      });
    }
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save completed tests
    await prefs.setStringList('completed_tests', _completedTests.toList());
    
    // Save answers (convert Map<int, String> to Map<String, String> for JSON)
    final Map<String, dynamic> answersToJson = _testAnswers.map((testId, answers) {
      final Map<String, String> stringKeyAnswers = answers.map((key, value) => MapEntry(key.toString(), value));
      return MapEntry(testId, stringKeyAnswers);
    });
    
    await prefs.setString('test_answers', jsonEncode(answersToJson));
  }

  void markTestCompleted(String testId, Map<int, String> answers) {
    _completedTests.add(testId);
    _testAnswers[testId] = Map.from(answers);
    _saveProgress();
    notifyListeners();
  }

  void deleteTestResult(String testId) {
    _completedTests.remove(testId);
    _testAnswers.remove(testId);
    _saveProgress();
    notifyListeners();
  }

  bool isTestCompleted(String testId) {
    return _completedTests.contains(testId);
  }

  Map<int, String>? getTestAnswers(String testId) {
    return _testAnswers[testId];
  }

  int getCompletedCountForBook(int bookNumber, {String? moduleType}) {
    if (moduleType == 'reading') {
      return _completedTests.where((id) => 
        id == 'cambridge_${bookNumber}_reading_test_1' ||
        id == 'cambridge_${bookNumber}_reading_test_2' ||
        id == 'cambridge_${bookNumber}_reading_test_3' ||
        id == 'cambridge_${bookNumber}_reading_test_4'
      ).length;
    } else if (moduleType == 'writing') {
      return _completedTests.where((id) => 
        id == 'cambridge_${bookNumber}_writing_test_1' ||
        id == 'cambridge_${bookNumber}_writing_test_2' ||
        id == 'cambridge_${bookNumber}_writing_test_3' ||
        id == 'cambridge_${bookNumber}_writing_test_4'
      ).length;
    } else if (moduleType == 'listening') {
      // Exactly match listening test IDs (1 to 4)
      return _completedTests.where((id) => 
        id == 'cambridge_${bookNumber}_test_1' ||
        id == 'cambridge_${bookNumber}_test_2' ||
        id == 'cambridge_${bookNumber}_test_3' ||
        id == 'cambridge_${bookNumber}_test_4'
      ).length;
    } else {
      // Default / Dashboard
      return _completedTests.where((id) => id.startsWith('cambridge_${bookNumber}_')).length;
    }
  }
}
