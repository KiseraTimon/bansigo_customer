// lib/shared/widgets/social_auth_button.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum SocialProvider { google, facebook }

class SocialAuthButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = provider == SocialProvider.google;
    final label = isGoogle ? 'Continue with Google' : 'Continue with Facebook';

    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(isGoogle),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: AppTextStyles.bodySemiBold.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon(bool isGoogle) {
    if (isGoogle) {
      return Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        child: const Text(
          'G',
          style: TextStyle(
            color: AppColors.googleRed,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            fontFamily: 'Roboto',
          ),
        ),
      );
    } else {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.facebookBlue,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Roboto',
          ),
        ),
      );
    }
  }
}
