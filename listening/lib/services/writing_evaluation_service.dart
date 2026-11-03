import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/writing_evaluation_model.dart';

class WritingEvaluationService {
  final Uri endpoint;

  WritingEvaluationService({String baseUrl = 'http://localhost:8787'})
    : endpoint = Uri.parse('$baseUrl/api/evaluate-writing');

  Future<WritingEvaluation> evaluate({
    required String testId,
    required String task1Question,
    required String task2Question,
    required String task1Answer,
    required String task2Answer,
    required int wordCount,
  }) async {
    final response = await http
        .post(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'testId': testId,
            'task1Question': task1Question,
            'task2Question': task2Question,
            'task1Answer': task1Answer,
            'task2Answer': task2Answer,
            'wordCount': wordCount,
          }),
        )
        .timeout(const Duration(seconds: 90));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['error'] ?? 'Evaluation request failed.');
    }
    return WritingEvaluation.fromJson(
      Map<String, dynamic>.from(body['evaluation'] as Map),
    );
  }
}
