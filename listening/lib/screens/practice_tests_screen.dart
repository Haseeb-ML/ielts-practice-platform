import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'package:provider/provider.dart';
import '../models/ielts_models.dart';
import '../providers/test_progress_provider.dart';
import 'test_selection_screen.dart';

class PracticeTestsScreen extends StatelessWidget {
  final String moduleType; // 'listening', 'reading', 'writing'
  final String title;

  const PracticeTestsScreen({
    super.key, 
    this.moduleType = 'listening',
    this.title = "Practice Tests",
  });

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<TestProgressProvider>();
    
    // Generate books 13 to 19 (in ascending order)
    final List<IELTSBook> books = List.generate(7, (index) => IELTSBook.cambridge(13 + index));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.primaryText), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cambridge IELTS Books 13-19", style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.s8),
            Text("Select a book to view its tests.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: AppSpacing.s32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: AppSpacing.s24,
                mainAxisSpacing: AppSpacing.s24,
                childAspectRatio: 1.1,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return _buildBookCard(context, books[index], progressProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, IELTSBook book, TestProgressProvider provider) {
    final int completedCount = provider.getCompletedCountForBook(book.bookNumber, moduleType: moduleType);
    final int totalTests = book.tests.length; // 4 full tests per book
    final double progress = totalTests > 0 ? (completedCount / totalTests) : 0.0;
    final int progressPercent = (progress * 100).round();

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TestSelectionScreen(book: book, moduleType: moduleType)));
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusCard)),
              ),
              child: Center(
                child: Text("IELTS\n${book.bookNumber}", textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primaryNavy)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.s4),
                Text("$totalTests Total Tests", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$completedCount / $totalTests completed", style: Theme.of(context).textTheme.labelSmall),
                    Text("$progressPercent%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
