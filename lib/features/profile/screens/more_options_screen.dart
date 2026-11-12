// lib/features/profile/screens/more_options_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login/login_flow_screen.dart';
import '../../address/screens/my_addresses_screen.dart';
import '../../wishlist/screens/wishlist_screen.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';
import 'contact_us_screen.dart';

class MoreOptionsScreen extends StatelessWidget {
  const MoreOptionsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out of your BansiGo account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.slateDark)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginFlowScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    final displayName = user != null
        ? (user.fullName.trim().isNotEmpty
            ? user.fullName
            : (user.email.isNotEmpty ? user.email.split('@').first : 'Tommy Omolo'))
        : 'Tommy Omolo';
    final displayPhone = user != null
        ? (user.phone.trim().isNotEmpty ? user.phone : 'No phone added')
        : '07XXXXXX24';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Title "More"
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Text(
                  'More',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),

              // 2. User Info Card matching inspo image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    // Stylized Avatar with Google picture rendering & orange/cyan gradient fallback
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF5722),
                            Color(0xFFFF9800),
                            Color(0xFF00BCD4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ClipOval(
                        child: user?.picture != null && user!.picture!.trim().isNotEmpty
                            ? Image.network(
                                user.picture!,
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayPhone,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 3. Exact Fields Requested by User
              // Item 1: Edit Profile
              _buildInspoMenuItem(
                context: context,
                icon: Icons.edit_outlined,
                iconColor: const Color(0xFF3B82F6),
                title: 'Edit Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              // Item 2: My Addresses
              _buildInspoMenuItem(
                context: context,
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF0F172A),
                title: 'My Addresses',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyAddressesScreen()),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              // Item 3: Payment Methods
              _buildInspoMenuItem(
                context: context,
                icon: Icons.credit_card_outlined,
                iconColor: const Color(0xFF0F172A),
                title: 'Payment Methods',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              // Item 4: My Wishlist
              _buildInspoMenuItem(
                context: context,
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFF0F172A),
                title: 'My Wishlist',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              // Item 5: Contact Us
              _buildInspoMenuItem(
                context: context,
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF22C55E),
                title: 'Contact Us',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              // Item 6: Logout
              _buildInspoMenuItem(
                context: context,
                icon: Icons.power_settings_new_rounded,
                iconColor: const Color(0xFFEF4444),
                title: 'Logout',
                textColor: const Color(0xFFEF4444),
                onTap: () => _showLogoutDialog(context),
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspoMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    Color textColor = const Color(0xFF1E293B),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodySemiBold.copyWith(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
