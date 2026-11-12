// lib/features/home/widgets/trust_banner.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TrustBanner extends StatelessWidget {
  const TrustBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFBBF7D0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildItem(
                icon: Icons.flash_on_rounded,
                title: '15-20 Min',
                subtitle: 'Delivery',
                color: AppColors.primaryDark,
              ),
            ),
            Container(width: 1, height: 24, color: const Color(0xFFBBF7D0)),
            Expanded(
              child: _buildItem(
                icon: Icons.verified_user_rounded,
                title: '100% Fresh',
                subtitle: 'Guaranteed',
                color: const Color(0xFF0F766E),
              ),
            ),
            Container(width: 1, height: 24, color: const Color(0xFFBBF7D0)),
            Expanded(
              child: _buildItem(
                icon: Icons.payments_rounded,
                title: 'M-Pesa / Cash',
                subtitle: 'On Delivery',
                color: const Color(0xFF15803D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: AppColors.slateDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 8.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
