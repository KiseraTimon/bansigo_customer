// lib/features/splash/widgets/onboarding_slide.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingSlide extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String description;
  final Widget? badge;

  const OnboardingSlide({
    super.key,
    required this.illustration,
    required this.title,
    required this.description,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (badge != null) ...[
            badge!,
            const SizedBox(height: 16),
          ],
          illustration,
          const SizedBox(height: 32),
          Text(
            title,
            style: AppTextStyles.h1.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.subtitle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
