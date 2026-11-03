import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/ielts_models.dart';
import '../models/reading_test_data_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/highlightable_text.dart';
import '../widgets/question_paper_widget.dart'; // We'll reuse the questions rendering logic if possible, or build custom
import '../widgets/resizable_split_view.dart';
import '../models/test_data_model.dart' as listening_models;
import 'result_screen.dart';

class ReadingTestScreen extends StatefulWidget {
  final IELTSTest? test;

  const ReadingTestScreen({super.key, this.test});

  @override
  State<ReadingTestScreen> createState() => _ReadingTestScreenState();
}

class _ReadingTestScreenState extends State<ReadingTestScreen> {
  bool _isLoading = true;
  ReadingTestDataModel? _testData;
  int _currentSectionIndex = 0;
  
  Map<int, String> _userAnswers = {};
  
  late Timer _timer;
  int _remainingSeconds = 60 * 60; // 60 minutes
  
  double _textScaleFactor = 1.0;
  
  final ScrollController _passageScrollController = ScrollController();
  
  final Map<int, GlobalKey> _questionKeys = {};

  late Map<int, dynamic> _correctAnswers;

  GlobalKey _getQuestionKey(int id) {
    if (!_questionKeys.containsKey(id)) {
      _questionKeys[id] = GlobalKey();
    }
    return _questionKeys[id]!;
  }

  @override
  void initState() {
    super.initState();
    _initCorrectAnswers();
    _loadTestData();
    _startTimer();
  }

  void _initCorrectAnswers() {
    if (widget.test?.id == 'cambridge_19_reading_test_2') {
      _correctAnswers = {
        1: "piston", 2: "coal", 3: "workshops", 4: ["labour", "labor"], 5: "quality", 6: ["railway", "railways"], 7: "sanitation",
        8: "NOT GIVEN", 9: "FALSE", 10: "NOT GIVEN", 11: "TRUE", 12: "TRUE", 13: "NOT GIVEN",
        14: "D", 15: "F", 16: "A", 17: "C", 18: "F", 19: "injury",
        20: "serves", 21: "excitement", 22: ["Visualisation", "Visualization"],
        23: ["B", "D"], 24: ["B", "D"], 25: ["A", "E"], 26: ["A", "E"],
        27: "H", 28: "A", 29: "C", 30: "B", 31: "J", 32: "I",
        33: "YES", 34: "NOT GIVEN", 35: "YES", 36: "NOT GIVEN", 37: "NO",
        38: "C", 39: "B", 40: "D"
      };
    } else {
      _correctAnswers = {
        1: "FALSE", 2: "FALSE", 3: "NOT GIVEN", 4: "FALSE", 5: "NOT GIVEN", 6: "TRUE", 7: "TRUE",
        8: "paint", 9: "topspin", 10: "training", 11: "intestines", 12: "weights", 13: "grips",
        14: "D", 15: "G", 16: "C", 17: "A", 18: "G", 19: "B",
        20: ["B", "D"], 21: ["B", "D"], 22: ["C", "E"], 23: ["C", "E"],
        24: "grain", 25: "punishment", 26: "ransom",
        27: "D", 28: "A", 29: "C", 30: "D",
        31: "G", 32: "J", 33: "H", 34: "B", 35: "E", 36: "C",
        37: "YES", 38: "NOT GIVEN", 39: "NO", 40: "NOT GIVEN"
      };
    }
  }

  Future<void> _loadTestData() async {
    try {
      final String fileName = widget.test?.dataFileName ?? 'cambridge_19_reading_test_1.json';
      final String response = await rootBundle.loadString('assets/data/$fileName');
      final data = await json.decode(response);
      setState(() {
        _testData = ReadingTestDataModel.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading Reading JSON: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Test data not available for ${widget.test?.title ?? ''}")),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        // Handle time up
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _passageScrollController.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Test?"),
        content: const Text("Your progress will be lost. Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Exit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _submitTest() {
    _timer.cancel();
    int score = 0;
    
    // Evaluate answers
    _correctAnswers.forEach((id, correctAnswer) {
      String userAnswer = _userAnswers[id]?.trim().toUpperCase() ?? "";
      if (correctAnswer is List) {
        // Multi-answer (e.g., choose 2 letters). Just check if it's in the list.
        // But wait, if they pick B for 20, and B for 21, it should count once?
        // Actually, for simplicity, if userAnswer is in correctAnswer list, we count it.
        if (correctAnswer.contains(userAnswer)) {
          // ensure they didn't use the same letter for both
          score++;
        }
      } else {
        String correctStr = correctAnswer.toString().toUpperCase();
        if (userAnswer == correctStr) {
          score++;
        }
      }
    });

    // Convert correct answers to match ResultScreen expectations
    Map<int, String> resultCorrectAnswers = {};
    _correctAnswers.forEach((key, value) {
      if (value is List) {
        resultCorrectAnswers[key] = value.join(' / ');
      } else {
        resultCorrectAnswers[key] = value.toString();
      }
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          test: widget.test,
          testId: widget.test?.id ?? 'cambridge_19_test_1',
          userAnswers: _userAnswers,
          testType: 'reading',
          overrideCorrectAnswers: resultCorrectAnswers,
          overrideEitherOrderGroups: const [
            [20, 21],
            [22, 23],
          ],
        ),
      ),
    );
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_testData == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load test data.")),
      );
    }

    final currentSection = _testData!.sections[_currentSectionIndex];

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_textScaleFactor),
          ),
          child: Column(
            children: [
              _buildHeader(context),
            Expanded(
              child: ResizableSplitView(
                initialRatio: 0.5,
                leftChild: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Scrollbar(
                    controller: _passageScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _passageScrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              currentSection.passageTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: HighlightableText(
                              text: currentSection.passage,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                rightChild: Container(
                  color: const Color(0xFFF9FAFB),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QuestionPaperWidget handles its own scrolling
                      Expanded(
                        child: _buildQuestionsList(currentSection),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
        ), // MediaQuery
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.surface),
                onPressed: () async {
                  if (await _onBackPressed()) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(width: AppSpacing.s16),
              const SizedBox(width: AppSpacing.s16),
              Text(
                "${widget.test?.title ?? 'Reading Test'} - ${_testData?.book ?? ''}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.surface),
              ),
            ],
          ),
          Row(
            children: [
              // Text Size Controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (_textScaleFactor > 0.8) _textScaleFactor -= 0.1;
                        });
                      },
                      child: const Icon(Icons.remove, size: 20, color: AppColors.secondaryText),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _textScaleFactor = 1.0;
                        });
                      },
                      child: const Icon(Icons.format_size, size: 20, color: AppColors.primaryText),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (_textScaleFactor < 1.6) _textScaleFactor += 0.1;
                        });
                      },
                      child: const Icon(Icons.add, size: 20, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.s4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.surface, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      _formattedTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              ElevatedButton(
                onPressed: () {
                  _submitTest();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 12),
                ),
                child: const Text("Submit Test", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(ReadingSectionModel section) {
    // Adapt Reading models to listening models for QuestionPaperWidget
    final convertedTestData = listening_models.TestDataModel(
      testId: _testData!.testId,
      book: _testData!.book,
      testNumber: _testData!.testNumber,
      audioFile: '',
      sections: _testData!.sections.map((s) => listening_models.SectionModel(
        sectionNumber: s.sectionNumber,
        instructions: s.instructions,
        topic: s.passageTitle,
        questions: s.questions,
      )).toList(),
    );

    return QuestionPaperWidget(
      testData: convertedTestData,
      selectedSection: section.sectionNumber,
      userAnswers: _userAnswers,
      onAnswerChanged: (id, answer) {
        setState(() {
          _userAnswers[id] = answer;
        });
      },
      onHighlightToggled: (word) {}, // Not used directly in this widget for passage
      questionKeys: _questionKeys,
    );
  }

  Widget _buildBottomNavigation() {
    if (_testData == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_testData!.sections.length, (index) {
            final sectionNum = index + 1;
            final isSelected = _currentSectionIndex == index;
            final section = _testData!.sections[index];
            final questions = section.questions.where((q) => q.type != 'instruction').toList();
            
            int answeredCount = 0;
            for (var q in questions) {
              if (_userAnswers.containsKey(q.id) && _userAnswers[q.id]!.isNotEmpty) {
                answeredCount++;
              }
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentSectionIndex = index;
                });
                if (_passageScrollController.hasClients) {
                  _passageScrollController.jumpTo(0);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.green : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Part $sectionNum",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 16),
                      Wrap(
                        spacing: 6,
                        children: questions.map((q) {
                          final bool isAnswered = _userAnswers.containsKey(q.id) && _userAnswers[q.id]!.isNotEmpty;
                          
                          // Ensure key exists
                          _getQuestionKey(q.id);
                          
                          return GestureDetector(
                            onTap: () {
                              final key = _questionKeys[q.id];
                              if (key != null && key.currentContext != null) {
                                Scrollable.ensureVisible(
                                  key.currentContext!,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: 0.1, // Show slightly below the top edge
                                );
                              }
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isAnswered ? Colors.green : AppColors.border),
                                color: Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${q.id}",
                                style: TextStyle(
                                  color: isAnswered ? Colors.green : AppColors.primaryText, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 12
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) {
                          if (questions.isEmpty) return const SizedBox();
                          int startId = questions.first.id;
                          if (questions.first.subIds != null && questions.first.subIds!.isNotEmpty) {
                            startId = questions.first.subIds!.first;
                          }
                          int endId = questions.last.id;
                          if (questions.last.subIds != null && questions.last.subIds!.isNotEmpty) {
                            endId = questions.last.subIds!.last;
                          }
                          return Text(
                            "($startId - $endId)",
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 16,
                            ),
                          );
                        }
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isRight = false,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryNavy,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      ),
      child: Row(
        children: [
          if (!isRight) Icon(icon),
          if (!isRight) const SizedBox(width: AppSpacing.s8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (isRight) const SizedBox(width: AppSpacing.s8),
          if (isRight) Icon(icon),
        ],
      ),
    );
  }
}
