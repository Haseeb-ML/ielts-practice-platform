import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'listening_test_screen.dart';
import 'transcript_screen.dart';
import '../models/ielts_models.dart';
import '../models/test_data_model.dart';

class ResultScreen extends StatefulWidget {
  final IELTSTest? test;
  final String? testId;
  final Map<int, String> userAnswers;
  final String testType;
  final Map<int, String>? overrideCorrectAnswers;
  final List<List<int>>? overrideEitherOrderGroups;

  const ResultScreen({
    super.key, 
    this.test, 
    this.testId, 
    required this.userAnswers,
    this.testType = 'listening',
    this.overrideCorrectAnswers,
    this.overrideEitherOrderGroups,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Map<int, String> get _correctAnswers {
    if (widget.overrideCorrectAnswers != null) {
      return widget.overrideCorrectAnswers!;
    }
    if (widget.testId == 'cambridge_13_test_2') {
      return {
        1: "races", 2: "insurance", 3: "Jerriz", 4: "25 / twenty-five", 5: "stadium",
        6: "park", 7: "coffee", 8: "leader", 9: "route", 10: "lights",
        11: "C", 12: "B", 13: "C", 14: "B", 15: "B", 16: "A", 17: "C", 18: "E", 19: "B", 20: "D",
        21: "B", 22: "A", 23: "C", 24: "C", 25: "A", 26: "A", 27: "C", 28: "D", 29: "G", 30: "B",
        31: "location", 32: "world", 33: "personal", 34: "attention", 35: "name", 36: "network", 37: "frequency", 38: "colour / color", 39: "brain", 40: "self"
      };
    }
    return {
      1: "choose", 2: "private", 3: "20 / twenty percent", 4: "healthy", 
      5: "bones", 6: "lecture", 7: "Arretsa", 8: "vegetarian", 9: "market", 10: "knife",
      11: "B", 12: "C", 13: "B", 14: "E", 15: "D", 16: "B", 17: "G", 18: "C", 19: "H", 20: "I",
      21: "A", 22: "C", 23: "B", 24: "C", 25: "B", 26: "G", 27: "C", 28: "H", 29: "A", 30: "E",
      31: "crow", 32: "cliffs", 33: "speed", 34: "brain(s)", 35: "food", 36: "behaviour(s) / behavior(s)", 37: "new", 38: "stress", 39: "tail(s)", 40: "permanent"
    };
  }

  List<List<int>> get _eitherOrderGroups {
    if (widget.overrideEitherOrderGroups != null) {
      return widget.overrideEitherOrderGroups!;
    }
    if (widget.testId == 'cambridge_13_test_2') {
      return [[17, 18], [19, 20]];
    }
    return [];
  }

  int _correctCount = 0;
  int _incorrectCount = 0;
  double _bandScore = 0.0;
  int _accuracy = 0;

  @override
  void initState() {
    super.initState();
    _calculateScore();
  }

  void _calculateScore() {
    int correct = 0;
    
    // Evaluate answers
    for (int i = 1; i <= 40; i++) {
      if (_isCorrect(i)) {
        correct++;
      }
    }
    
    _correctCount = correct;
    _incorrectCount = 40 - correct;
    _accuracy = ((correct / 40) * 100).round();
    _bandScore = _calculateIELTSBand(correct);
  }

  double _calculateIELTSBand(int correct) {
    if (widget.testType == 'reading') {
      // Reading Academic Band Scores
      if (correct >= 39) return 9.0;
      if (correct >= 37) return 8.5;
      if (correct >= 35) return 8.0;
      if (correct >= 33) return 7.5;
      if (correct >= 30) return 7.0;
      if (correct >= 27) return 6.5;
      if (correct >= 23) return 6.0;
      if (correct >= 19) return 5.5;
      if (correct >= 15) return 5.0;
      if (correct >= 13) return 4.5;
      if (correct >= 10) return 4.0;
      if (correct >= 8) return 3.5;
      if (correct >= 6) return 3.0;
      if (correct >= 4) return 2.5;
      if (correct >= 2) return 2.0;
      return 0.0;
    } else {
      // Listening Band Scores
      if (correct >= 39) return 9.0;
      if (correct >= 37) return 8.5;
      if (correct >= 35) return 8.0;
      if (correct >= 32) return 7.5;
      if (correct >= 30) return 7.0;
      if (correct >= 26) return 6.5;
      if (correct >= 23) return 6.0;
      if (correct >= 18) return 5.5;
      if (correct >= 16) return 5.0;
      if (correct >= 13) return 4.5;
      if (correct >= 10) return 4.0;
      if (correct >= 8) return 3.5;
      if (correct >= 6) return 3.0;
      if (correct >= 4) return 2.5;
      if (correct >= 2) return 2.0;
      return 0.0;
    }
  }

  bool _isCorrect(int qNum) {
    String userAns = widget.userAnswers[qNum] ?? "";
    if (userAns.trim().isEmpty) return false;

    // Check if part of either order group
    for (var group in _eitherOrderGroups) {
      if (group.contains(qNum)) {
        // Collect all user answers for this group
        List<String> groupUserAnswers = group.map((id) => widget.userAnswers[id] ?? "").toList();
        // Collect all correct answers for this group
        List<String> groupCorrectAnswers = group.map((id) => _correctAnswers[id] ?? "").toList();
        
        // Find which position qNum is in the group (e.g. 0 or 1)
        int indexInGroup = group.indexOf(qNum);
        
        // We need to match userAns to ANY of the groupCorrectAnswers that hasn't been "claimed" by another user answer
        // A simple way is to check if userAns matches any correct answer in the group.
        // If the user provided duplicates (e.g. "C", "C"), they only get 1 point.
        bool matched = false;
        for (String correctAns in groupCorrectAnswers) {
          if (_checkAnswer(userAns, correctAns)) {
            matched = true;
            break;
          }
        }
        
        // If matched, ensure it's not a duplicate guess that already matched something else.
        if (matched) {
            // Count how many unique correct guesses the user made in this group
            int totalValidMatches = 0;
            Set<String> matchedCorrects = {};
            for (String uAns in groupUserAnswers) {
                for (String cAns in groupCorrectAnswers) {
                    if (!matchedCorrects.contains(cAns) && _checkAnswer(uAns, cAns)) {
                        matchedCorrects.add(cAns);
                        totalValidMatches++;
                        break;
                    }
                }
            }
            // If they made 2 valid matches, they get points for both questions.
            // If they made 1 valid match, only the FIRST question in the group (or the one containing the answer) gets a point.
            // To simplify: if userAns matches a correct answer, and they didn't duplicate it.
            // Let's just say a point is given if userAns matches one of the correct answers, 
            // AND we process the group as a whole.
            // Actually, we can just check if userAns is among the correct answers. 
            // If user answered C and C for Q17 and Q18, they should only get 1 point.
            // To handle this, we can compute how many points they earned for the group, and assign it to the questions.
            if (indexInGroup < totalValidMatches) return true;
            return false;
        }
        return false;
      }
    }

    String correctAns = _correctAnswers[qNum] ?? "";
    return _checkAnswer(userAns, correctAns);
  }

  bool _checkAnswer(String userAns, String correctAns) {
    if (userAns.trim().isEmpty) return false;
    userAns = userAns.trim().toLowerCase();
    
    List<String> possibleCorrectAnswers = correctAns.toLowerCase().split('/').map((s) => s.trim()).toList();
    
    for (String possibleCorrect in possibleCorrectAnswers) {
      String withoutOptional = possibleCorrect.replaceAll(RegExp(r'\(.*?\)'), '').trim();
      String withOptional = possibleCorrect.replaceAll('(', '').replaceAll(')', '').trim();
      
      if (userAns == withoutOptional || userAns == withOptional || userAns == possibleCorrect) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Soft background matching image
      appBar: _buildHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
        child: Column(
          children: [
            _buildScoreCard(),
            const SizedBox(height: 24),
            _buildSectionCards(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildQuestionAnalysis()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildSidePanels()),
              ],
            )
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.testType == 'reading' ? "Reading Test Result" : "Listening Test Result", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(widget.test?.title ?? "Cambridge IELTS Test", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            onPressed: () {},
            child: const Text("Review Mistakes", style: TextStyle(color: Colors.white)),
          ),
        ),
        if (widget.testType != 'reading')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryNavy),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TranscriptScreen(
                      test: widget.test,
                      testId: widget.testId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.subtitles_outlined, color: AppColors.primaryNavy, size: 18),
              label: const Text("Transcript", style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: OutlinedButton(
            onPressed: () {
              // Just pop to go back to the test screen to try again
              Navigator.pop(context);
            },
            child: const Text("Try Again", style: TextStyle(color: Colors.black)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context), // Go back to dashboard
            child: const Text("Dashboard", style: TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3666), Color(0xFF0F687A)], // Navy to Teal gradient
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Circular progress for score
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.tealAccent, width: 8), // Placeholder for circular progress
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$_correctCount", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const Text("/ 40", style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 64),
          _buildScoreStat("BAND SCORE", _bandScore.toString(), color: Colors.tealAccent),
          const SizedBox(width: 48),
          _buildScoreStat("CORRECT", "$_correctCount"),
          const SizedBox(width: 48),
          _buildScoreStat("INCORRECT", "$_incorrectCount"),
          const SizedBox(width: 48),
          _buildScoreStat("ACCURACY", "$_accuracy%"),
        ],
      ),
    );
  }

  Widget _buildScoreStat(String label, String value, {Color color = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 36, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionCards() {
    int getPartScore(int start, int end) {
      int score = 0;
      for (int i = start; i <= end; i++) {
        if (_isCorrect(i)) score++;
      }
      return score;
    }

    if (widget.testType == 'reading') {
      int p1 = getPartScore(1, 13);
      int p2 = getPartScore(14, 26);
      int p3 = getPartScore(27, 40);

      return Row(
        children: [
          Expanded(child: _buildSingleSectionCard("PASSAGE 1", "Reading Questions 1-13", p1, 13)),
          const SizedBox(width: 16),
          Expanded(child: _buildSingleSectionCard("PASSAGE 2", "Reading Questions 14-26", p2, 13)),
          const SizedBox(width: 16),
          Expanded(child: _buildSingleSectionCard("PASSAGE 3", "Reading Questions 27-40", p3, 14)),
        ],
      );
    } else {
      int p1 = getPartScore(1, 10);
      int p2 = getPartScore(11, 20);
      int p3 = getPartScore(21, 30);
      int p4 = getPartScore(31, 40);

      return Row(
        children: [
          Expanded(child: _buildSingleSectionCard("PART 1", "Form & Note Completion", p1, 10)),
          const SizedBox(width: 16),
          Expanded(child: _buildSingleSectionCard("PART 2", "Multiple Choice & Matching", p2, 10)),
          const SizedBox(width: 16),
          Expanded(child: _buildSingleSectionCard("PART 3", "Note & Table Completion", p3, 10)),
          const SizedBox(width: 16),
          Expanded(child: _buildSingleSectionCard("PART 4", "Sentence & Map Labelling", p4, 10)),
        ],
      );
    }
  }

  Widget _buildSingleSectionCard(String part, String topic, int correct, int total) {
    int accuracy = ((correct / total) * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(part, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(topic, style: const TextStyle(color: Colors.black87, fontSize: 14)),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "$correct", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                    TextSpan(text: "/$total", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: correct / total,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Text("$accuracy% accuracy", style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuestionAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Question Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _buildAnalysisTable(),
        ],
      ),
    );
  }

  Widget _buildAnalysisTable() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text("Q", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(child: Text("Your Answer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(child: Text("Correct Answer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              SizedBox(width: 100, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
            ],
          ),
        ),
        const Divider(height: 1),
        for (int i = 1; i <= 40; i++)
          _buildAnalysisRow(i),
      ],
    );
  }

  Widget _buildAnalysisRow(int qNum) {
    bool isCorrect = _isCorrect(qNum);
    String userAns = widget.userAnswers[qNum] ?? "";
    String correctAns = _correctAnswers[qNum] ?? "";
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          SizedBox(
            width: 40, 
            child: Text(qNum.toString().padLeft(2, '0'), style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? AppColors.success : AppColors.error)),
          ),
          Expanded(
            child: Text(userAns.isEmpty ? "-" : userAns, style: TextStyle(color: isCorrect ? Colors.black87 : AppColors.error, fontWeight: userAns.isNotEmpty ? FontWeight.w500 : FontWeight.normal)),
          ),
          Expanded(
            child: Text(correctAns, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 100, 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isCorrect ? AppColors.success.withOpacity(0.5) : AppColors.error.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isCorrect ? Icons.check : Icons.close, color: isCorrect ? AppColors.success : AppColors.error, size: 14),
                  const SizedBox(width: 4),
                  Text(isCorrect ? "Correct" : "Incorrect", style: TextStyle(color: isCorrect ? AppColors.success : AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanels() {
    return Column(
      children: [
        _buildPerformanceInsights(),
        const SizedBox(height: 24),
        _buildYourMistakes(),
      ],
    );
  }

  Widget _buildPerformanceInsights() {
    int getPartScore(int start, int end) {
      int score = 0;
      for (int i = start; i <= end; i++) {
        if (_isCorrect(i)) score++;
      }
      return score;
    }

    List<Map<String, dynamic>> parts = [
      {"name": "Part 1", "score": getPartScore(1, 10), "total": 10},
      {"name": "Part 2", "score": getPartScore(11, 20), "total": 10},
      {"name": "Part 3", "score": getPartScore(21, 30), "total": 10},
      {"name": "Part 4", "score": getPartScore(31, 40), "total": 10},
    ];

    parts.sort((a, b) => b["score"].compareTo(a["score"]));

    var strongest = parts.first;
    var weakest = parts.last;

    int strongAcc = ((strongest["score"] as int) / 10 * 100).round();
    int weakAcc = ((weakest["score"] as int) / 10 * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Performance Insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInsightCard("STRONGEST AREA", strongest["name"] as String, "$strongAcc%", AppColors.success),
          const SizedBox(height: 16),
          _buildInsightCard("NEEDS IMPROVEMENT", weakest["name"] as String, "$weakAcc%", AppColors.error),
          const SizedBox(height: 16),
          _buildInsightCard("RECOMMENDED FOCUS", weakest["name"] as String, "Practice this section more", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String label, String title, String sub, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(sub.contains("%") ? "$sub accuracy" : sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildYourMistakes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Mistakes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ..._buildMistakesList(),
          if (_buildMistakesList().isNotEmpty)
            const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {},
              child: const Text("Review All Mistakes →", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildMistakesList() {
    List<Widget> mistakes = [];
    int count = 0;
    
    for (int i = 1; i <= 40; i++) {
      String userAns = widget.userAnswers[i] ?? "";
      if (!_isCorrect(i) && userAns.trim().isNotEmpty) {
        mistakes.add(_buildMistakeItem(i, userAns, _correctAnswers[i] ?? ""));
        mistakes.add(const SizedBox(height: 12));
        count++;
        if (count >= 5) break; // Only show top 5 mistakes
      }
    }
    
    if (mistakes.isEmpty) {
      return [
        const Text("Great job! You didn't make any mistakes (or haven't answered any questions).", 
                   style: TextStyle(color: Colors.grey))
      ];
    }
    
    // Remove the last SizedBox
    mistakes.removeLast();
    return mistakes;
  }

  Widget _buildMistakeItem(int q, String user, String correct) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Question $q", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("Your: ", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text(user, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text("Correct: ", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text(correct, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  void _showFullTranscriptDialog(BuildContext context) async {
    final String dataFileName = widget.test?.dataFileName ?? 'cambridge_13_test_1.json';
    try {
      final String jsonStr = await rootBundle.loadString('assets/data/$dataFileName');
      final data = json.decode(jsonStr);
      final testData = TestDataModel.fromJson(data);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return DefaultTabController(
            length: testData.sections.length,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, color: AppColors.primaryNavy),
                      const SizedBox(width: 8),
                      Text(
                        "${widget.test?.title ?? 'Test'} Listening Transcript",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: SizedBox(
                width: 750,
                height: 520,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: AppColors.primaryNavy,
                      unselectedLabelColor: AppColors.secondaryText,
                      indicatorColor: AppColors.primaryNavy,
                      indicatorWeight: 3,
                      tabs: [
                        for (int i = 0; i < testData.sections.length; i++)
                          Tab(text: "Part ${testData.sections[i].sectionNumber}"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          for (var section in testData.sections)
                            Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                                child: SelectableText(
                                  section.transcript ?? "Transcript not available for this part.",
                                  style: const TextStyle(fontSize: 14.5, height: 1.6, color: AppColors.primaryText),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not load transcript for this test.")),
        );
      }
    }
  }
}
