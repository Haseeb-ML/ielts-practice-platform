import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../models/ielts_models.dart';
import 'package:provider/provider.dart';
import '../providers/test_progress_provider.dart';
import 'listening_test_screen.dart';
import 'result_screen.dart';
import 'practice_tests_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TestProgressProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(context),
                  const SizedBox(height: AppSpacing.s32),
                  _buildQuickStats(context),
                  const SizedBox(height: AppSpacing.s48),
                  _buildModulesGrid(context),
                  const SizedBox(height: AppSpacing.s48),
                  _buildCompletedTestsSection(context, provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      pinned: true,
      elevation: 1,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Good morning 👋", style: Theme.of(context).textTheme.titleLarge),
              Text("Continue your IELTS Listening practice.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
            ],
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.search, color: AppColors.primaryText), onPressed: () {}),
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryText), onPressed: () {}),
              const SizedBox(width: AppSpacing.s8),
              const CircleAvatar(
                backgroundColor: AppColors.border,
                child: Icon(Icons.person, color: AppColors.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s32),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Master your IELTS Preparation", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.surface)),
                const SizedBox(height: AppSpacing.s8),
                Text("Practice all modules and track your overall progress.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.accentLight)),
                const SizedBox(height: AppSpacing.s24),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusButton)),
                      ),
                      onPressed: () {},
                      child: const Text("Start Learning", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.surface),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusButton)),
                      ),
                      onPressed: () {},
                      child: const Text("View Syllabus", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Column(
              children: [
                Text("Target Band", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.accentLight)),
                Text("8.0", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.surface)),
                const SizedBox(height: AppSpacing.s8),
                Text("Current: 7.0", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.border)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, Icons.assignment_turned_in, "Tests Completed", "12", "↑ 2 this week")),
        const SizedBox(width: AppSpacing.s16),
        Expanded(child: _buildStatCard(context, Icons.bar_chart, "Overall Average Band", "7.5", "↑ 0.5 this month")),
        const SizedBox(width: AppSpacing.s16),
        Expanded(child: _buildStatCard(context, Icons.local_fire_department, "Current Streak", "5 Days", "Keep it up!")),
        const SizedBox(width: AppSpacing.s16),
        Expanded(child: _buildStatCard(context, Icons.check_circle_outline, "Total Accuracy", "78%", "↑ 5% this week")),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value, String trend) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.accentTeal),
              Text(trend, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.s4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  Widget _buildLibrarySection(BuildContext context) {
    // Show only 4 recent books on dashboard
    final List<IELTSBook> books = List.generate(4, (index) => IELTSBook.cambridge(18 - index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Practice Books", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.s4),
        Text("Choose a Cambridge IELTS test to practice.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: AppSpacing.s24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            crossAxisSpacing: AppSpacing.s16,
            mainAxisSpacing: AppSpacing.s16,
            childAspectRatio: 0.8,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return _buildBookCard(context, books[index]);
          },
        ),
      ],
    );
  }

  Widget _buildBookCard(BuildContext context, IELTSBook book) {
    return Container(
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
                Text("${book.tests.length} Total Tests", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("0 / ${book.tests.length} completed", style: Theme.of(context).textTheme.labelSmall),
                    const Text("0%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                LinearProgressIndicator(
                  value: 0.0,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: AppSpacing.s16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to Test Selection Screen (to be built) or directly to a test
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ListeningTestScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusButton)),
                    ),
                    child: const Text("View Tests"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Learning Modules", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.s4),
        Text("Select a module to start practicing.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: AppSpacing.s24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: AppSpacing.s16,
          mainAxisSpacing: AppSpacing.s16,
          childAspectRatio: 1.2,
          children: [
            _buildModuleCard(context, "Listening", Icons.headset, AppColors.primaryNavy, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PracticeTestsScreen()));
            }),
            _buildModuleCard(context, "Reading", Icons.menu_book, AppColors.accentTeal, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reading module coming soon")));
            }),
            _buildModuleCard(context, "Writing", Icons.edit_note, Colors.indigo, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PracticeTestsScreen(
                    moduleType: 'writing',
                    title: 'Writing Practice',
                  ),
                ),
              );
            }),
            _buildModuleCard(context, "Speaking", Icons.mic, Colors.deepPurple, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Speaking module coming soon")));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTestsSection(BuildContext context, TestProgressProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Completed Tests", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.s4),
        Text("Review your performance or clear history.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: AppSpacing.s24),
        if (provider.completedTests.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.history, size: 48, color: AppColors.border),
                const SizedBox(height: AppSpacing.s16),
                Text("No recent tests", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.secondaryText)),
                const SizedBox(height: AppSpacing.s8),
                Text("Start practicing to see your completed tests here.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.completedTests.length,
            itemBuilder: (context, index) {
              String testId = provider.completedTests.elementAt(index);
              // Format ID, assuming 'cambridge_13_test_1'
              String displayName = testId;
              if (testId.startsWith('cambridge_')) {
                var parts = testId.split('_');
                if (parts.length >= 4) {
                  displayName = "Cambridge IELTS ${parts[1]} - Test ${parts[3]}";
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.s4),
                        Text("Status: Completed", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            final Map<int, String> answers = provider.getTestAnswers(testId) ?? <int, String>{};
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(testId: testId, userAnswers: answers)));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentTeal,
                            side: const BorderSide(color: AppColors.accentTeal),
                          ),
                          child: const Text("View Results"),
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
                                        provider.deleteTestResult(testId);
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
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
