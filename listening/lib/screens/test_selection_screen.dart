import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'package:provider/provider.dart';
import '../models/ielts_models.dart';
import '../providers/test_progress_provider.dart';
import 'listening_test_screen.dart';
import 'result_screen.dart';
import 'reading_test_screen.dart';
import 'listening_tricks_screen.dart';
import 'writing_test_screen.dart';

class TestSelectionScreen extends StatelessWidget {
  final IELTSBook book;
  final String moduleType; // 'listening', 'reading', 'writing'

  const TestSelectionScreen({
    super.key, 
    required this.book,
    this.moduleType = 'listening',
  });

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<TestProgressProvider>();
    final int completedCount = progressProvider.getCompletedCountForBook(book.bookNumber);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.titleLarge),
            Text("Practice Tests", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.secondaryText)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Center(
              child: Text(
                "$completedCount / ${book.tests.length} completed",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primaryNavy),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moduleType == 'listening') _buildTestSection(context, "Listening Tests", book.tests, progressProvider),
            if (moduleType == 'reading') _buildTestSection(context, "Reading Tests", book.readingTests, progressProvider),
            if (moduleType == 'writing') _buildTestSection(context, "Writing Tests", book.writingTests, progressProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(BuildContext context, String title, List<IELTSTest> tests, TestProgressProvider progressProvider) {
    if (tests.isEmpty) return const SizedBox.shrink();
    
    final bool showTricksCard = (moduleType == 'listening');
    final int itemCount = tests.length + (showTricksCard ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.s24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            crossAxisSpacing: AppSpacing.s24,
            mainAxisSpacing: AppSpacing.s24,
            childAspectRatio: 1.5,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index < tests.length) {
              return _buildTestCard(context, tests[index], progressProvider);
            } else {
              return _buildTricksCard(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTricksCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListeningTricksScreen()),
        );
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), AppColors.primaryNavy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text("🎯 ", style: TextStyle(fontSize: 18)),
                    Text(
                      "Listening Tricks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: const Text(
                    "MCQ Strategy",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            const Text(
              "4-Step MCQ system & Part 2/3 listening methods for high scores.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListeningTricksScreen()),
                  );
                },
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: const Text("View Tricks & Tips", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusButton)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, IELTSTest test, TestProgressProvider provider) {
    final bool isCompleted = provider.isTestCompleted(test.id);

    return InkWell(
      onTap: () {
        if (test.id == 'cambridge_13_test_1' || test.id == 'cambridge_13_test_2') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListeningTestScreen(test: test)));
        } else if (test.id == 'cambridge_19_reading_test_1' || test.id == 'cambridge_19_reading_test_2') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReadingTestScreen(test: test)));
        } else if (test.id == 'cambridge_19_writing_test_1') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => WritingTestScreen(test: test)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon")),
          );
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${test.type[0].toUpperCase()}${test.type.substring(1)} ${test.title}", style: Theme.of(context).textTheme.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.accentTeal.withOpacity(0.1) : AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                ),
                child: Text(isCompleted ? "Completed" : "Not Started", style: TextStyle(color: isCompleted ? AppColors.accentTeal : AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.secondaryText),
              const SizedBox(width: AppSpacing.s4),
              Text(test.type == 'writing' ? "~60 minutes" : (test.type == 'reading' ? "~60 minutes" : "~40 minutes"), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
              const SizedBox(width: AppSpacing.s16),
              const Icon(Icons.format_list_numbered, size: 16, color: AppColors.secondaryText),
              const SizedBox(width: AppSpacing.s4),
              Text(test.type == 'writing' ? "2 Tasks" : "${test.totalQuestions} Questions", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (test.type == 'listening' && (test.id == 'cambridge_13_test_1' || test.id == 'cambridge_13_test_2' || test.id == 'cambridge_13_test_3')) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ListeningTestScreen(test: test)));
                } else if (test.type == 'reading' && (test.id == 'cambridge_19_reading_test_1' || test.id == 'cambridge_19_reading_test_2')) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReadingTestScreen(test: test)));
                } else if (test.type == 'writing' && test.id == 'cambridge_19_writing_test_1') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WritingTestScreen(test: test)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Coming soon")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
              backgroundColor: ((test.type == 'listening' && (test.id == 'cambridge_13_test_1' || test.id == 'cambridge_13_test_2' || test.id == 'cambridge_13_test_3')) || (test.type == 'reading' && (test.id == 'cambridge_19_reading_test_1' || test.id == 'cambridge_19_reading_test_2')) || (test.type == 'writing' && test.id == 'cambridge_19_writing_test_1')) ? AppColors.primaryNavy : Colors.grey.shade400,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusButton)),
              ),
              child: Text(((test.type == 'listening' && (test.id == 'cambridge_13_test_1' || test.id == 'cambridge_13_test_2' || test.id == 'cambridge_13_test_3')) || (test.type == 'reading' && (test.id == 'cambridge_19_reading_test_1' || test.id == 'cambridge_19_reading_test_2')) || (test.type == 'writing' && test.id == 'cambridge_19_writing_test_1'))
                ? (isCompleted ? "Retake Test" : "Start Test") 
                : "Coming Soon", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(height: AppSpacing.s8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final Map<int, String> answers = provider.getTestAnswers(test.id) ?? <int, String>{};
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(testId: test.id, userAnswers: answers)));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentTeal,
                      side: const BorderSide(color: AppColors.accentTeal),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusButton)),
                    ),
                    child: const Text("View Results", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.error),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Result"),
                          content: const Text("Are you sure you want to delete this test result?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.surface),
                              onPressed: () {
                                provider.deleteTestResult(test.id);
                                Navigator.pop(ctx);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
      ),
    );
  }
}
