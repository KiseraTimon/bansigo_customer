// lib/features/home/widgets/home_header.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../shared/widgets/app_toast.dart';
class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final bool hasUnreadNotifications;

  const HomeHeader({
    super.key,
    this.onNotificationTap,
    this.hasUnreadNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 16, top: 12, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "BansiGo" Title
          Text(
            'BansiGo',
            style: AppTextStyles.brandTitle.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),

          // Notification Bell
          InkWell(
            onTap: onNotificationTap ?? () {
              AppToast.show(context, 'Notifications (0 unread)', type: AppToastType.info);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 26,
                    color: AppColors.slateDark,
                  ),
                  if (hasUnreadNotifications)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
