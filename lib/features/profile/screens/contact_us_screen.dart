// lib/features/profile/screens/contact_us_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../shared/widgets/app_toast.dart';
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Us',
          style: AppTextStyles.h1.copyWith(fontSize: 19),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: AppColors.primaryDark, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We\'re here to help 24/7',
                          style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Have questions about your order or grocery deliveries in Migori? Reach out anytime.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildContactTile(
              context: context,
              title: 'Chat with us',
              subtitle: 'Start a live chat with our customer support team',
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF16A34A),
              onTap: () {
                AppToast.show(context, 'Starting live support chat with BansiGo Concierge...', type: AppToastType.info);
              },
            ),
            const SizedBox(height: 12),

            _buildContactTile(
              context: context,
              title: 'Talk to our Support',
              subtitle: '+254 700 000 000 (Toll free for orders)',
              icon: Icons.phone_outlined,
              iconColor: const Color(0xFFEA580C),
              onTap: () {
                AppToast.show(context, 'Dialing BansiGo Customer Support: +254 700 000 000', type: AppToastType.info);
              },
            ),
            const SizedBox(height: 12),

            _buildContactTile(
              context: context,
              title: 'Mail us',
              subtitle: 'support@bansigo.store',
              icon: Icons.mail_outline_rounded,
              iconColor: const Color(0xFF0284C7),
              onTap: () {
                AppToast.show(context, 'Opening mail to support@bansigo.store', type: AppToastType.info);
              },
            ),
            const SizedBox(height: 12),

            _buildContactTile(
              context: context,
              title: 'Message to facebook page',
              subtitle: 'facebook.com/BansiGoOfficial',
              icon: Icons.facebook_rounded,
              iconColor: const Color(0xFF1877F2),
              onTap: () {
                AppToast.show(context, 'Opening Facebook page: facebook.com/BansiGoOfficial', type: AppToastType.info);
              },
            ),
            const SizedBox(height: 24),

            // Store address card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bansi Mega Supermarket',
                          style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
                        ),
                        Text(
                          'Wasweta 1 / Migori Town, Kenya • Open 7:00 AM - 10:00 PM',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
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

  Widget _buildContactTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
