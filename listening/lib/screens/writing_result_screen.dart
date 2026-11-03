import 'package:flutter/material.dart';

import '../models/writing_evaluation_model.dart';
import '../theme/app_spacing.dart';

class WritingResultScreen extends StatefulWidget {
  final String testId, testTitle, taskType, question, userAnswer;
  final int wordCount, timeTaken;
  final DateTime submissionDate;
  final WritingEvaluation evaluation;
  final AiEvaluationStatus status;

  const WritingResultScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    required this.taskType,
    required this.question,
    required this.userAnswer,
    required this.wordCount,
    required this.timeTaken,
    required this.submissionDate,
    required this.evaluation,
    this.status = AiEvaluationStatus.completed,
  });

  @override
  State<WritingResultScreen> createState() => _WritingResultScreenState();
}

class _WritingResultScreenState extends State<WritingResultScreen> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    if (widget.status != AiEvaluationStatus.completed) {
      return _statusScreen(context);
    }
    final evaluation = widget.evaluation;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_note, color: Color(0xFFE9833A)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Writing Evaluation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.testTitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          const Center(
            child: Text(
              'Test Submitted',
              style: TextStyle(
                color: Color(0xFFE9833A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Center(
            child: Text(
              _dateLabel(widget.submissionDate),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(evaluation),
                const SizedBox(height: 28),
                _section('Band Score Breakdown', _scoreGrid(evaluation)),
                const SizedBox(height: 24),
                _section('Your Performance', _performance(evaluation)),
                const SizedBox(height: 24),
                _section(
                  'Your Top Priorities',
                  _priorities(evaluation.priorityAreas),
                ),
                const SizedBox(height: 24),
                _section('Grammar Analysis', _grammar(evaluation)),
                const SizedBox(height: 24),
                _section('Vocabulary Analysis', _vocabulary(evaluation)),
                const SizedBox(height: 24),
                _section('Repeated Words', _repeated(evaluation.repeatedWords)),
                const SizedBox(height: 24),
                _section('Coherence & Cohesion', _coherence(evaluation)),
                const SizedBox(height: 24),
                _section(evaluation.taskLabel, _taskAnalysis(evaluation)),
                const SizedBox(height: 24),
                _section(
                  'Sentence Analysis',
                  _sentences(evaluation.sentenceAnalysis),
                ),
                const SizedBox(height: 24),
                _section(
                  'Your Improvement Plan',
                  _improvementPlan(evaluation.improvementPlan),
                ),
                const SizedBox(height: 24),
                _section('Recommended Next Practice', _recommendations()),
                const SizedBox(height: 24),
                _answerPanel(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Writing'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _showAnswer = true),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View My Answer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusScreen(BuildContext context) {
    final isFailed = widget.status == AiEvaluationStatus.failed;
    final isOffline = widget.status == AiEvaluationStatus.pending;
    final title = isFailed
        ? "AI evaluation couldn't be completed."
        : isOffline
        ? 'Your writing is saved.'
        : 'Analyzing your writing...';
    final description = isFailed
        ? 'Your writing has been saved safely. You can try the AI evaluation again when connected to the internet.'
        : isOffline
        ? 'AI evaluation requires an internet connection.'
        : 'Your response is being checked against IELTS writing criteria.';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F7),
      appBar: AppBar(
        title: const Text('Writing Evaluation'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE6E2DE)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFailed
                    ? Icons.cloud_off_outlined
                    : isOffline
                    ? Icons.save_outlined
                    : Icons.auto_awesome,
                size: 44,
                color: const Color(0xFFE9833A),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
              if (!isOffline && !isFailed) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: Color(0xFFE9833A)),
                const SizedBox(height: 22),
                const Text(
                  '✓ Reading your response\n✓ Checking task requirements\n● Analyzing grammar\n○ Checking vocabulary\n○ Evaluating coherence\n○ Preparing improvement plan',
                  textAlign: TextAlign.left,
                  style: TextStyle(height: 1.7),
                ),
              ],
              if (isOffline || isFailed) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(isFailed ? 'Try Again' : 'Analyze When Online'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Review My Answer'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(WritingEvaluation e) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4EA),
      border: Border.all(color: const Color(0xFFF4C8A5)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Evaluation',
              style: TextStyle(
                color: Color(0xFFE9833A),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estimated IELTS Band',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              e.overallBand.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 58,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE9833A),
              ),
            ),
            Text(
              'AI estimated score - not an official IELTS result',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Band: 7.0',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'You are making good progress. Focus on grammar, vocabulary variety, and idea development to reach Band 7.',
                style: TextStyle(color: Colors.grey.shade800, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _section(String title, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE6E2DE)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );

  Widget _scoreGrid(WritingEvaluation e) => LayoutBuilder(
    builder: (context, constraints) {
      final scores = [
        ('Task Response', e.taskScore, e.taskFeedback),
        ('Coherence & Cohesion', e.coherenceScore, e.coherenceFeedback),
        (
          'Lexical Resource',
          e.vocabularyScore,
          'Vocabulary is generally clear, but some basic words are repeated.',
        ),
        (
          'Grammatical Range & Accuracy',
          e.grammarScore,
          'Meaning is clear, though several agreement and article errors remain.',
        ),
      ];
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth > 800 ? 4 : 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.65,
        ),
        itemCount: scores.length,
        itemBuilder: (_, i) =>
            _scoreCard(scores[i].$1, scores[i].$2, scores[i].$3),
      );
    },
  );

  Widget _scoreCard(String title, double score, String text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBF8),
      border: Border.all(color: const Color(0xFFF0E2D7)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              score.toStringAsFixed(1),
              style: const TextStyle(
                color: Color(0xFFE9833A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: score / 9,
          color: const Color(0xFFE9833A),
          backgroundColor: const Color(0xFFF2E6DC),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _performance(WritingEvaluation e) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in [
        ('Task Achievement / Response', e.taskScore),
        ('Coherence & Cohesion', e.coherenceScore),
        ('Lexical Resource', e.vocabularyScore),
        ('Grammar', e.grammarScore),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(width: 190, child: Text(item.$1)),
              Expanded(
                child: LinearProgressIndicator(
                  value: item.$2 / 9,
                  color: const Color(0xFFE9833A),
                  backgroundColor: const Color(0xFFF0ECE8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item.$2.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      const SizedBox(height: 8),
      Text(
        e.overallFeedback,
        style: TextStyle(color: Colors.grey.shade700, height: 1.5),
      ),
    ],
  );

  Widget _priorities(List<ImprovementItem> items) => Column(
    children: [
      for (final item in items)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFFFF0E4),
            foregroundColor: const Color(0xFFE9833A),
            child: Text('${item.priority}'),
          ),
          title: Text(
            item.category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(item.problem),
          trailing: Text(
            item.level,
            style: TextStyle(
              color: item.level == 'High'
                  ? Colors.deepOrange
                  : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  );

  Widget _grammar(WritingEvaluation e) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Grammar Band: ${e.grammarScore.toStringAsFixed(1)}    Total Issues: ${e.grammarMistakes.length}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      for (final mistake in e.grammarMistakes)
        _detailCard(
          'Original',
          mistake.original,
          'Correction',
          mistake.correction,
          '${mistake.category}: ${mistake.explanation}',
        ),
    ],
  );

  Widget _vocabulary(WritingEvaluation e) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Lexical Resource: ${e.vocabularyScore.toStringAsFixed(1)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      for (final item in e.vocabularyIssues)
        _detailCard(
          item.issue,
          item.originalWord,
          'Suggested',
          item.suggestion,
          item.explanation,
        ),
    ],
  );

  Widget _detailCard(
    String firstLabel,
    String first,
    String secondLabel,
    String second,
    String explanation,
  ) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFCFCFB),
      border: Border.all(color: const Color(0xFFEAE6E1)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Wrap(
      spacing: 28,
      runSpacing: 8,
      children: [
        SizedBox(width: 280, child: _labelValue(firstLabel, first)),
        SizedBox(width: 280, child: _labelValue(secondLabel, second)),
        SizedBox(width: 330, child: _labelValue('Explanation', explanation)),
      ],
    ),
  );
  Widget _labelValue(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(height: 1.35)),
    ],
  );

  Widget _repeated(List<RepeatedWord> words) => Column(
    children: [
      for (final word in words)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 80, child: Text('${word.frequency} times')),
              Expanded(
                child: Text(
                  word.alternatives.join(', '),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
    ],
  );
  Widget _coherence(WritingEvaluation e) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Band: ${e.coherenceScore.toStringAsFixed(1)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(e.coherenceFeedback),
      const SizedBox(height: 14),
      _bulletGroup('Strengths', e.coherenceStrengths),
      _bulletGroup('Needs Improvement', e.coherenceImprovements),
    ],
  );
  Widget _bulletGroup(String title, List<String> values) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        for (final value in values)
          Text(
            '  • $value',
            style: TextStyle(color: Colors.grey.shade700, height: 1.6),
          ),
      ],
    ),
  );
  Widget _taskAnalysis(WritingEvaluation e) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in [
        'Question understood',
        'Position is clear',
        'Main ideas present',
        'Ideas need more development',
        'Examples included',
      ])
        Row(
          children: [
            Icon(
              item.contains('need')
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              size: 18,
              color: item.contains('need') ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(item),
          ],
        ),
      const SizedBox(height: 8),
      Text('Overview: ${e.overviewStatus}'),
      const SizedBox(height: 8),
      Text(e.taskFeedback),
    ],
  );
  Widget _sentences(List<SentenceFeedback> list) => Column(
    children: [
      for (final item in list)
        _detailCard(
          item.type,
          item.original,
          'Improved',
          item.improved,
          item.explanation,
        ),
    ],
  );
  Widget _improvementPlan(List<ImprovementItem> items) => Column(
    children: [
      for (final item in items)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Text(
            'Step ${item.priority}',
            style: const TextStyle(
              color: Color(0xFFE9833A),
              fontWeight: FontWeight.bold,
            ),
          ),
          title: Text(
            item.category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${item.recommendation}\nPractice: ${item.practice}'),
        ),
    ],
  );
  Widget _recommendations() => Row(
    children: [
      for (final item in [
        'Grammar Practice\nArticles & Subject-Verb Agreement',
        'Vocabulary Practice\nTopic Vocabulary & Word Variety',
        'Writing Practice\nDevelop Supporting Ideas',
      ])
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text('$item\nPractice Now', textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
    ],
  );
  Widget _answerPanel() => ExpansionTile(
    title: const Text(
      'View My Original Answer',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    initiallyExpanded: _showAnswer,
    onExpansionChanged: (value) => setState(() => _showAnswer = value),
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userAnswer.isEmpty
                  ? 'No answer was entered.'
                  : widget.userAnswer,
              style: const TextStyle(height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.wordCount} words  |  ${widget.taskType}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    ],
  );
  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
