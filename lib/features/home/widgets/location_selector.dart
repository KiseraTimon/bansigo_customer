// lib/features/home/widgets/location_selector.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LocationSelector extends StatelessWidget {
  final String location;
  final String supermarketDistanceNote;
  final bool isFarApart;
  final VoidCallback? onTap;

  const LocationSelector({
    super.key,
    this.location = 'Select Location, Migori',
    this.supermarketDistanceNote = '15–20 mins delivery • 1.2 km from Bansi Mega Supermarket',
    this.isFarApart = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delivery address: $location\n$supermarketDistanceNote'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Pin Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isFarApart ? AppColors.error : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFarApart ? Icons.warning_rounded : Icons.location_on_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Location Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your Location',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        location,
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: AppColors.slateDark,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Chevron Right
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.slateDark,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Note saying how long out the location is from the supermarket
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                color: isFarApart ? const Color(0xFFFEF2F2) : const Color(0xFFF1FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFarApart
                      ? AppColors.error.withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFarApart ? Icons.warning_amber_rounded : Icons.timer_outlined,
                    size: 13.5,
                    color: isFarApart ? AppColors.error : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      supermarketDistanceNote,
                      style: AppTextStyles.caption.copyWith(
                        color: isFarApart ? AppColors.error : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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