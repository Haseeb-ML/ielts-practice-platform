import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class QuestionNavigatorWidget extends StatelessWidget {
  const QuestionNavigatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Text(
            "Questions",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.s16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: AppSpacing.s8,
              mainAxisSpacing: AppSpacing.s8,
            ),
            itemCount: 40,
            itemBuilder: (context, index) {
              int questionNumber = index + 1;
              return _buildQuestionItem(context, questionNumber);
            },
          ),
        ),
        const Divider(height: 1),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildQuestionItem(BuildContext context, int number) {
    // Simulating some states for demonstration
    bool isCurrent = number == 12;
    bool isAnswered = number < 12;
    bool isMarked = number == 5 || number == 18;

    Color bgColor = AppColors.surface;
    Color textColor = AppColors.primaryText;
    Color borderColor = AppColors.border;

    if (isCurrent) {
      bgColor = AppColors.primaryNavy;
      textColor = AppColors.surface;
      borderColor = AppColors.primaryNavy;
    } else if (isAnswered) {
      bgColor = AppColors.primaryNavy.withOpacity(0.1);
      textColor = AppColors.primaryNavy;
      borderColor = AppColors.primaryNavy.withOpacity(0.3);
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: isCurrent || isAnswered ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (isMarked)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegendItem(context, "Current", AppColors.primaryNavy, isFilled: true),
          const SizedBox(height: AppSpacing.s8),
          _buildLegendItem(context, "Answered", AppColors.primaryNavy.withOpacity(0.1), borderColor: AppColors.primaryNavy.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.s8),
          _buildLegendItem(context, "Unanswered", AppColors.surface, borderColor: AppColors.border),
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text("Review", style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, {bool isFilled = false, Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor ?? color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
