// lib/shared/widgets/brand_logo.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class BrandLogo extends StatelessWidget {
  final double fontSize;
  final bool showDot;

  const BrandLogo({
    super.key,
    this.fontSize = 28,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.brandTitle.copyWith(fontSize: fontSize),
        children: [
          const TextSpan(text: 'Bansi'),
          TextSpan(
            text: 'Go',
            style: TextStyle(color: AppColors.primary),
          ),
          if (showDot)
            const TextSpan(
              text: '.',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
