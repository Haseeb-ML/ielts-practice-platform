import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AudioPanelWidget extends StatelessWidget {
  const AudioPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Text(
            "Listening Audio",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Divider(height: 1),
        _buildPlayer(context),
        const Divider(height: 1),
        _buildPartInfo(context),
        const Divider(height: 1),
        _buildTestRules(context),
      ],
    );
  }

  Widget _buildPlayer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_outlined, color: AppColors.secondaryText),
                onPressed: () {},
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryNavy,
                ),
                child: IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.play_arrow, color: AppColors.surface),
                  onPressed: () {},
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("1.0x", style: TextStyle(color: AppColors.secondaryText)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("03:42", style: Theme.of(context).textTheme.labelSmall),
              Text("30:00", style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          LinearProgressIndicator(
            value: 0.15,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.audioProgress),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildPartInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NOW PLAYING", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.s4),
          Text("Part 1", style: Theme.of(context).textTheme.headlineMedium),
          Text("Questions 1–10", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              const Icon(Icons.graphic_eq, color: AppColors.primaryNavy, size: 16),
              const SizedBox(width: AppSpacing.s8),
              Text("Status: Playing", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.accentLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.accentTeal, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    Text("Instructions", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Text("Listen carefully and answer Questions 1–10. Write your answers in the boxes.", style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestRules(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text("Test Rules", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
        childrenPadding: const EdgeInsets.only(left: AppSpacing.s16, right: AppSpacing.s16, bottom: AppSpacing.s16),
        children: [
          _buildRule("Listen carefully to the recording."),
          _buildRule("Answer all questions."),
          _buildRule("Check your answers before submitting."),
          _buildRule("Do not close the test while audio is playing."),
        ],
      ),
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: AppColors.secondaryText, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13))),
        ],
      ),
    );
  }
}
