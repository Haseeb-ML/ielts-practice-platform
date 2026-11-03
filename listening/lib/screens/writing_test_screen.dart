import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ielts_models.dart';
import '../models/writing_test_data_model.dart';
import '../models/writing_evaluation_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/resizable_split_view.dart';
import '../screens/writing_result_screen.dart';
import '../services/writing_attempt_storage.dart';
import '../services/writing_evaluation_service.dart';
import '../providers/test_progress_provider.dart';

class WritingTestScreen extends StatefulWidget {
  final IELTSTest? test;

  const WritingTestScreen({super.key, this.test});

  @override
  State<WritingTestScreen> createState() => _WritingTestScreenState();
}

class _WritingTestScreenState extends State<WritingTestScreen> {
  final WritingTestDataModel _testData = WritingTestDataModel.cambridge19Test1;
  final Map<int, TextEditingController> _controllers = {
    1: TextEditingController(),
    2: TextEditingController(),
  };
  late final Timer _timer;
  int _selectedTaskIndex = 0;
  int _remainingSeconds = 60 * 60;

  WritingTaskModel get _task => _testData.tasks[_selectedTaskIndex];
  TextEditingController get _controller => _controllers[_task.taskNumber]!;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int _wordCount(String value) {
    final matches = RegExp(r"[A-Za-z0-9]+(?:[-'][A-Za-z0-9]+)*")
        .allMatches(value.trim());
    return matches.length;
  }

  String get _minutesRemaining {
    final minutes = _remainingSeconds ~/ 60;
    return '$minutes minutes remaining';
  }

  void _selectTask(int index) {
    setState(() {
      _selectedTaskIndex = index;
    });
  }

  void _goPrevious() {
    if (_selectedTaskIndex > 0) _selectTask(_selectedTaskIndex - 1);
  }

  void _goNext() {
    if (_selectedTaskIndex < _testData.tasks.length - 1) {
      _selectTask(_selectedTaskIndex + 1);
    }
  }

  Future<void> _submitTest() async {
    final answers = _controllers.values
        .map((controller) => controller.text.trim())
        .where((answer) => answer.isNotEmpty)
        .join('\n\n');
    final wordCount = _wordCount(answers);
    final submissionDate = DateTime.now();
    final attempt = WritingAttempt(
      testId: widget.test?.id ?? _testData.id,
      testTitle: widget.test?.title ?? _testData.title,
      taskType: 'Task 1 & Task 2',
      question: _testData.tasks
          .map((task) => 'Task ${task.taskNumber}: ${task.prompt}')
          .join('\n\n'),
      userAnswer: answers,
      wordCount: wordCount,
      timeTaken: 60 * 60 - _remainingSeconds,
      submissionDate: submissionDate,
      status: AiEvaluationStatus.pending,
    );
    await WritingAttemptStorage().saveAttempt(attempt);
    if (!mounted) return;
    context.read<TestProgressProvider>().markTestCompleted(
      attempt.testId,
      const {},
    );
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFFE9833A)),
            SizedBox(width: 18),
            Expanded(child: Text('Analyzing your writing...')),
          ],
        ),
      ),
    );
    WritingEvaluation? evaluation;
    AiEvaluationStatus status = AiEvaluationStatus.completed;
    try {
      evaluation = await WritingEvaluationService().evaluate(
        testId: attempt.testId,
        task1Question: _testData.tasks[0].prompt,
        task2Question: _testData.tasks[1].prompt,
        task1Answer: _controllers[1]!.text.trim(),
        task2Answer: _controllers[2]!.text.trim(),
        wordCount: attempt.wordCount,
      );
    } catch (_) {
      status = AiEvaluationStatus.failed;
      evaluation = WritingEvaluation.mock();
    }
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WritingResultScreen(
          testId: attempt.testId,
          testTitle: attempt.testTitle,
          taskType: attempt.taskType,
          question: attempt.question,
          userAnswer: attempt.userAnswer,
          wordCount: attempt.wordCount,
          timeTaken: attempt.timeTaken,
          submissionDate: attempt.submissionDate,
          evaluation: evaluation!,
          status: status,
        ),
      ),
    );
  }

  Future<bool> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Close Test?'),
          content: const Text(
            'Are you sure you want to close this test? Your progress and answers will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continue Test'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Exit Test'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  Future<void> _handleBackPressed() async {
    if (await _confirmExit() && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ResizableSplitView(
                initialRatio: 0.47,
                leftChild: _buildQuestionPanel(),
                rightChild: _buildEditorPanel(),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            hoverColor: AppColors.warning.withOpacity(0.12),
            splashRadius: 22,
            onPressed: _handleBackPressed,
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          ),
          const SizedBox(width: AppSpacing.s8),
          Text(
            _testData.title,
            style: const TextStyle(fontSize: 15, color: AppColors.primaryText),
          ),
          const Spacer(),
          const Icon(Icons.timer_outlined, color: AppColors.warning, size: 22),
          Text(
            _minutesRemaining.split(' ').first,
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          Text(
            'minutes remaining',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _submitTest,
            icon: const Icon(Icons.send, size: 18),
            label: const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9833A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPanel() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 34, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.5,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Task ${_task.taskNumber}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: _task.prompt),
                ],
              ),
            ),
            if (_task.instruction.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s24),
              Text(
                _task.instruction,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Write at least ${_task.minimumWords} words.',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
            if (_task.taskNumber == 1) ...[
              const SizedBox(height: AppSpacing.s32),
              const Center(child: _WritingTaskChart()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditorPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(28, 34, 26, 22),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final count = _wordCount(_controller.text);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.primaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type here.',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFF7A1A)),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFF7A1A),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Text(
                'Words Count: $count',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildCircleNavButton(
                    icon: Icons.chevron_left,
                    enabled: _selectedTaskIndex > 0,
                    onPressed: _goPrevious,
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  _buildCircleNavButton(
                    icon: Icons.chevron_right,
                    enabled: _selectedTaskIndex < _testData.tasks.length - 1,
                    onPressed: _goNext,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 46,
      height: 46,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          side: BorderSide(
            color: enabled ? const Color(0xFFFF7A1A) : const Color(0xFFF3D8C8),
          ),
          foregroundColor: enabled
              ? const Color(0xFFFF7A1A)
              : const Color(0xFFF3D8C8),
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: List.generate(_testData.tasks.length, (index) {
          final task = _testData.tasks[index];
          final selected = _selectedTaskIndex == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : AppSpacing.s8,
                right: index == 0 ? AppSpacing.s8 : 0,
              ),
              child: OutlinedButton(
                onPressed: () => _selectTask(index),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.primaryNavy,
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFFFF7A1A)
                        : const Color(0xFFCFE3DA),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  index == 0
                      ? 'Part ${task.taskNumber} :'
                      : 'Part ${task.taskNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WritingTaskChart extends StatelessWidget {
  const _WritingTaskChart();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.55,
      child: CustomPaint(painter: _WritingTaskChartPainter()),
    );
  }
}

class _WritingTaskChartPainter extends CustomPainter {
  final List<int> years = const [2000, 2005, 2010, 2015, 2020];
  final Map<String, List<double>> data = const {
    'Film club': [64, 62, 60, 64, 66],
    'Martial arts': [36, 32, 38, 34, 36],
    'Amateur dramatics': [25, 28, 20, 14, 6],
    'Table tennis': [16, 20, 20, 35, 54],
    'Musical performances': [0, 0, 12, 16, 18],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final axisPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1.4;
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    const left = 74.0;
    const top = 58.0;
    const bottom = 54.0;
    final right = size.width * 0.66;
    final chart = Rect.fromLTRB(left, top, right, size.height - bottom);
    final legend = Rect.fromLTWH(
      right + 24,
      top + 50,
      size.width - right - 34,
      150,
    );

    void drawText(
      String value,
      Offset offset,
      TextStyle style, {
      TextAlign align = TextAlign.left,
    }) {
      textPainter.text = TextSpan(text: value, style: style);
      textPainter.textAlign = align;
      textPainter.layout(maxWidth: size.width);
      textPainter.paint(canvas, offset);
    }

    drawText(
      'Number of participants, by activity 2000-2020',
      Offset(size.width * 0.12, 12),
      const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF42464D),
      ),
    );

    for (int y = 0; y <= 70; y += 10) {
      final dy = chart.bottom - (y / 70) * chart.height;
      canvas.drawLine(
        Offset(chart.left, dy),
        Offset(chart.right, dy),
        gridPaint,
      );
      drawText(
        '$y',
        Offset(chart.left - 30, dy - 8),
        TextStyle(fontSize: 12, color: Colors.grey.shade700),
      );
    }
    canvas.drawLine(
      Offset(chart.left, chart.bottom),
      Offset(chart.right, chart.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chart.left, chart.top),
      Offset(chart.left, chart.bottom),
      axisPaint,
    );

    for (int i = 0; i < years.length; i++) {
      final dx = chart.left + i * chart.width / (years.length - 1);
      canvas.drawLine(
        Offset(dx, chart.bottom),
        Offset(dx, chart.bottom + 8),
        axisPaint,
      );
      drawText(
        '${years[i]}',
        Offset(dx - 18, chart.bottom + 14),
        TextStyle(fontSize: 12, color: Colors.grey.shade700),
      );
    }

    canvas.save();
    canvas.translate(14, chart.center.dy + 52);
    canvas.rotate(-1.5708);
    drawText(
      'Number of participants',
      Offset.zero,
      const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF42464D),
      ),
    );
    canvas.restore();
    drawText(
      'Year',
      Offset(chart.center.dx - 16, size.height - 22),
      const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF42464D),
      ),
    );

    final styles = <String, Paint>{
      'Film club': Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
      'Martial arts': Paint()
        ..color = Colors.grey.shade500
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
      'Amateur dramatics': Paint()
        ..color = Colors.grey.shade800
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
      'Table tennis': Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
      'Musical performances': Paint()
        ..color = Colors.blueGrey.shade300
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    };

    Offset point(int index, double value) {
      return Offset(
        chart.left + index * chart.width / (years.length - 1),
        chart.bottom - (value / 70) * chart.height,
      );
    }

    data.forEach((label, values) {
      final path = Path()
        ..moveTo(point(0, values[0]).dx, point(0, values[0]).dy);
      for (int i = 1; i < values.length; i++) {
        path.lineTo(point(i, values[i]).dx, point(i, values[i]).dy);
      }
      canvas.drawPath(path, styles[label]!);
      for (int i = 0; i < values.length; i++) {
        final p = point(i, values[i]);
        canvas.drawCircle(p, 4.5, Paint()..color = Colors.white);
        canvas.drawCircle(
          p,
          4.5,
          Paint()
            ..color = styles[label]!.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    });

    canvas.drawRect(
      legend,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.grey.shade500,
    );
    var legendY = legend.top + 22;
    data.keys.toList().asMap().forEach((index, label) {
      final y = legendY + index * 25;
      canvas.drawLine(
        Offset(legend.left + 14, y),
        Offset(legend.left + 48, y),
        styles[label]!,
      );
      canvas.drawCircle(
        Offset(legend.left + 31, y),
        4,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(legend.left + 31, y),
        4,
        Paint()
          ..color = styles[label]!.color
          ..style = PaintingStyle.stroke,
      );
      drawText(
        label,
        Offset(legend.left + 58, y - 8),
        TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
