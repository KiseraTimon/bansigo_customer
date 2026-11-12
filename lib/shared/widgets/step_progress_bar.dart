// lib/shared/widgets/step_progress_bar.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index <= currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 3,
              right: index == totalSteps - 1 ? 0 : 3,
            ),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
