import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/writing_evaluation_model.dart';

class WritingAttemptStorage {
  static const _key = 'writing_attempts';

  Future<void> saveAttempt(WritingAttempt attempt) async {
    final preferences = await SharedPreferences.getInstance();
    final attempts = preferences.getStringList(_key) ?? <String>[];
    attempts.removeWhere(
      (item) =>
          (jsonDecode(item) as Map<String, dynamic>)['testId'] ==
          attempt.testId,
    );
    attempts.add(jsonEncode(attempt.toJson()));
    await preferences.setStringList(_key, attempts);
  }
}
