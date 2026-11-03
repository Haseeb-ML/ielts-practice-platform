import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ListeningTricksScreen extends StatelessWidget {
  const ListeningTricksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Listening Tricks & Strategies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryText)),
            Text("Master IELTS Listening MCQs", style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Center(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryNavy, Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text("🎯", style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "New MCQ Method",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppSpacing.s4),
                            Text(
                              "Follow this 4-step system to boost your Listening MCQ score",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.s24),

                // Step 1 Card
                _buildCard(
                  context,
                  badgeText: "STEP 1",
                  badgeColor: AppColors.primaryNavy,
                  title: "Question Ka Purpose Identify Karo",
                  subtitle: "Question mein word dekho aur purpose samjho:",
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppSpacing.s12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildPurposeRow("Why?", "Reason"),
                        _buildDivider(),
                        _buildPurposeRow("What?", "Information"),
                        _buildDivider(),
                        _buildPurposeRow("Where?", "Place"),
                        _buildDivider(),
                        _buildPurposeRow("When?", "Time"),
                        _buildDivider(),
                        _buildPurposeRow("Who?", "Person"),
                        _buildDivider(),
                        _buildPurposeRow("problem?", "Problem"),
                        _buildDivider(),
                        _buildPurposeRow("advantage?", "Benefit"),
                        _buildDivider(),
                        _buildPurposeRow("agree?", "Common Opinion"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.s24),

                // Step 2 / Observation Strategy Card
                _buildCard(
                  context,
                  badgeText: "IMPORTANT STRATEGY",
                  badgeColor: const Color(0xFFE11D48), // Vibrant Red/Rose
                  title: "Part 2 & Part 3 MCQs Special Technique",
                  subtitle: "Audio start hone se pehle ye observe karo:",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Example Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(AppSpacing.s12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Suppose Question Hai:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: AppSpacing.s8),
                            Text(
                              "What does the speaker say about the museum?",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: AppSpacing.s8),
                            Text("A. It is difficult to reach.", style: TextStyle(color: Colors.black87)),
                            Text("B. It has recently been renovated.", style: TextStyle(color: Colors.black87)),
                            Text("C. It is popular with tourists.", style: TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s16),

                      // Pro Tip Highlight Box
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(AppSpacing.s12),
                          border: Border.all(color: const Color(0xFF6EE7B7)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("💡", style: TextStyle(fontSize: 24)),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Golden Rule:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF065F46),
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s4),
                                  const Text(
                                    "Tumhein poora sentence baar baar read nahi karna.\nTum sirf mentally ye pakro:",
                                    style: TextStyle(
                                      color: Color(0xFF047857),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF10B981)),
                                    ),
                                    child: const Text(
                                      "Museum → difficult to reach / renovated / tourists",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF064E3B),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s8),
                                  const Text(
                                    "Bas. Audio mein ab tumhara brain in 3 possibilities ko listen karega.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF047857),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              border: Border.all(color: badgeColor.withOpacity(0.3)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          child,
        ],
      ),
    );
  }

  Widget _buildPurposeRow(String keyword, String meaning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, size: 18, color: AppColors.primaryNavy),
              const SizedBox(width: AppSpacing.s8),
              Text(
                keyword,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.secondaryText),
              const SizedBox(width: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meaning,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.accentTeal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.border);
  }
}
