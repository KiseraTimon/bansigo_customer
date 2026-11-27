// lib/features/notifications/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

import '../../../shared/widgets/app_toast.dart';
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;
    final isLoading = notificationProvider.isLoading;
    final activeFilter = notificationProvider.activeFilter;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.h1.copyWith(fontSize: 19),
        ),
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notificationProvider.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.primary),
              label: const Text(
                'Mark All Read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (notifications.any((n) => n.isRead))
            TextButton.icon(
              onPressed: () => notificationProvider.clearReadNotifications(),
              icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: AppColors.textSecondary),
              label: const Text(
                'Clear Read',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('all', 'All', activeFilter, notificationProvider),
                const SizedBox(width: 8),
                _buildFilterChip('promo', 'Offers', activeFilter, notificationProvider),
                const SizedBox(width: 8),
                _buildFilterChip('delivery', 'Deliveries', activeFilter, notificationProvider),
                const SizedBox(width: 8),
                _buildFilterChip('system', 'System', activeFilter, notificationProvider),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : notifications.isEmpty
              ? _buildEmptyNotifications(context)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => notificationProvider.loadNotifications(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return _buildNotificationCard(context, item, notificationProvider);
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterChip(
    String filterKey,
    String label,
    String currentFilter,
    NotificationProvider provider,
  ) {
    final isSelected = currentFilter == filterKey;
    return InkWell(
      onTap: () => provider.setFilter(filterKey),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.slateDark,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel item,
    NotificationProvider provider,
  ) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => provider.deleteNotification(item.id),
      child: InkWell(
      onTap: () {
        provider.markAsRead(item.id);
        AppToast.show(context, item.title, type: AppToastType.info, duration: const Duration(milliseconds: 900));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead ? const Color(0xFFF1F5F9) : AppColors.primary.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 13.5,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.slateDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item.createdAt,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildEmptyNotifications(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 38,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'All Caught Up!',
              style: AppTextStyles.h2.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'You have no new notifications right now. Order updates and store deals will appear here.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
