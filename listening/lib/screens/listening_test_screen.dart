import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/question_navigator_widget.dart';
import '../widgets/audio_panel_widget.dart';
import '../widgets/question_paper_widget.dart';
import '../widgets/inline_audio_player_widget.dart';
import '../models/test_data_model.dart';
import '../models/ielts_models.dart';
import 'package:provider/provider.dart';
import '../providers/test_progress_provider.dart';
import 'result_screen.dart';
import 'transcript_screen.dart';

class ListeningTestScreen extends StatefulWidget {
  final IELTSTest? test;
  const ListeningTestScreen({super.key, this.test});

  @override
  State<ListeningTestScreen> createState() => _ListeningTestScreenState();
}

class _ListeningTestScreenState extends State<ListeningTestScreen> {
  TestDataModel? _testData;
  bool _isLoading = true;
  int _selectedPart = 1;
  Timer? _timer;
  int _remainingSeconds = 60 * 40; // 40 minutes for listening
  
  double _textScaleFactor = 1.0;
  final Map<int, String> _userAnswers = {};
  
  bool _isHighlighterActive = false;
  final Set<String> _highlightedWords = {};

  @override
  void initState() {
    super.initState();
    _loadTestData();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Time's Up!", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Your 40 minutes are over and the test has ended."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: AppColors.surface),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                final String testId = widget.test?.id ?? 'cambridge_13_test_1_test_1';
                Provider.of<TestProgressProvider>(context, listen: false).markTestCompleted(testId, _userAnswers);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      test: widget.test,
                      testId: widget.test?.id,
                      userAnswers: _userAnswers,
                    ),
                  ),
                );
              },
              child: const Text("View Results"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<bool> _onBackPressed() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quit Test?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to quit the test? Your progress will not be saved."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Quit"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _loadTestData() async {
    try {
      final String fileName = widget.test?.dataFileName ?? 'cambridge_13_test_1.json';
      final String response = await rootBundle.loadString('assets/data/$fileName');
      final data = await json.decode(response);
      setState(() {
        _testData = TestDataModel.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading JSON: $e");
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_testData == null) {
      return const Scaffold(body: Center(child: Text("Error loading test data")));
    }

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
              InlineAudioPlayerWidget(
                audioAsset: _testData!.audioFile,
              ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CENTER: Question Paper
                Expanded(
                  child: Container(
                    color: const Color(0xFFF9FAFB), // Very light gray for paper
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s24),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.s8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildQuestionPaper(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
        ), // closes Column
        ), // closes MediaQuery
      ), // closes Scaffold
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
                icon: const Icon(Icons.arrow_back, color: AppColors.surface),
                onPressed: () => Navigator.maybePop(context),
              ),
              const SizedBox(width: AppSpacing.s16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cambridge IELTS 18", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.accentLight)),
                  Text(widget.test != null ? widget.test!.title : "Test 1", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.surface)),
                ],
              ),
            ],
          ),
          Text("Listening", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.surface)),
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
                    const Icon(Icons.text_fields, size: 20, color: AppColors.primaryText),
                    const SizedBox(width: 8),
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
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.surface, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    Text(_formatTime(_remainingSeconds), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.surface)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Container(
                decoration: BoxDecoration(
                  color: _isHighlighterActive ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                  border: Border.all(color: _isHighlighterActive ? Colors.yellow : Colors.transparent),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.highlight,
                    color: _isHighlighterActive ? Colors.yellow : AppColors.surface,
                  ),
                  tooltip: "Highlighter Pen",
                  onPressed: () {
                    setState(() {
                      _isHighlighterActive = !_isHighlighterActive;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              IconButton(
                icon: const Icon(Icons.help_outline, color: AppColors.surface),
                onPressed: () {},
              ),
              const SizedBox(width: AppSpacing.s16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: AppColors.surface,
                ),
                onPressed: () {
                  _showSubmitModal(context);
                },
                child: const Text("Submit Test"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNavigator() {
    return const QuestionNavigatorWidget();
  }

  Widget _buildQuestionPaper() {
    if (_testData == null) return const SizedBox();
    return QuestionPaperWidget(
      testData: _testData!,
      selectedSection: _selectedPart,
      userAnswers: _userAnswers,
      isHighlighterActive: _isHighlighterActive,
      highlightedWords: _highlightedWords,
      onHighlightToggled: (wordId) {
        setState(() {
          if (_highlightedWords.contains(wordId)) {
            _highlightedWords.remove(wordId);
          } else {
            _highlightedWords.add(wordId);
          }
        });
      },
      onAnswerChanged: (id, value) {
        setState(() {
          _userAnswers[id] = value;
        });
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 1; i <= 4; i++)
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPart = i;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedPart == i ? AppColors.primaryNavy.withOpacity(0.1) : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedPart == i ? AppColors.primaryNavy : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    "Part $i",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _selectedPart == i ? FontWeight.bold : FontWeight.w600,
                      color: _selectedPart == i ? AppColors.primaryNavy : AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioPanel() {
    return const AudioPanelWidget();
  }

  void _showSubmitModal(BuildContext context) {
    int answered = _userAnswers.values.where((v) => v.trim().isNotEmpty).length;
    int unanswered = 40 - answered;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Submit Test?", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(unanswered > 0 ? "You still have $unanswered unanswered questions." : "You have answered all questions!"),
              const SizedBox(height: AppSpacing.s16),
              _buildModalStatRow("Answered:", "$answered / 40"),
              _buildModalStatRow("Unanswered:", "$unanswered", color: AppColors.error),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Review Answers"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, foregroundColor: AppColors.surface),
              onPressed: () {
                _timer?.cancel();
                Navigator.pop(context);
                final String testId = widget.test?.id ?? 'cambridge_13_test_1_test_1';
                Provider.of<TestProgressProvider>(context, listen: false).markTestCompleted(testId, _userAnswers);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      test: widget.test,
                      testId: widget.test?.id,
                      userAnswers: _userAnswers,
                    ),
                  ),
                );
              },
              child: const Text("Submit Test"),
            ),
          ],
        );
      },
    );
  }

  void _showTranscriptDialog() {
    if (_testData == null) return;
    
    SectionModel? currentSection;
    try {
      currentSection = _testData!.sections.firstWhere((s) => s.sectionNumber == _selectedPart);
    } catch (_) {}

    final String scriptText = currentSection?.transcript ?? "Transcript not available for this part.";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.subtitles_outlined, color: AppColors.primaryNavy),
                  const SizedBox(width: 8),
                  Text(
                    "Part $_selectedPart Audio Script",
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
            width: 650,
            height: 450,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(right: 16),
                child: SelectableText(
                  scriptText,
                  style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.primaryText),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: color ?? AppColors.primaryNavy, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
