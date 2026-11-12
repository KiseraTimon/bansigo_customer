// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/server_config_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login/login_flow_screen.dart';
import '../../auth/screens/verification/email_verification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditProfileSheet(AuthProvider auth) {
    final user = auth.currentUser;
    final firstNameController = TextEditingController(text: user?.firstName ?? '');
    final lastNameController = TextEditingController(text: user?.lastName ?? '');
    final usernameController = TextEditingController(text: user?.username ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Edit Profile Information', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    'Update your personal information below',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: firstNameController,
                    label: 'First Name',
                    hint: 'e.g. John',
                    prefix: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                    validator: (v) => Validators.validateName(v, fieldName: 'First name'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: lastNameController,
                    label: 'Last Name',
                    hint: 'e.g. Doe',
                    prefix: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                    validator: (v) => Validators.validateName(v, fieldName: 'Last name'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: usernameController,
                    label: 'Username',
                    hint: 'e.g. johndoe',
                    prefix: const Icon(Icons.alternate_email, size: 20, color: AppColors.textSecondary),
                    validator: (v) => Validators.validateUsername(v, required: false),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    hint: '+254...',
                    keyboardType: TextInputType.phone,
                    prefix: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textSecondary),
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Save Changes',
                    isLoading: auth.isLoading,
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(sheetContext);
                        final rawPhone = phoneController.text.trim();
                        final normalisedPhone = Validators.normalisePhone(rawPhone) ?? rawPhone;
                        final success = await auth.updateProfile(
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          username: usernameController.text.trim(),
                          phone: normalisedPhone,
                        );
                        if (!mounted) return;
                        nav.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? 'Profile updated successfully!' : (auth.errorMessage ?? 'Update failed'),
                            ),
                            backgroundColor: success ? AppColors.primaryDark : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(AuthProvider auth) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Change Password', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your current password and choose a new one',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: currentPasswordController,
                    label: 'Current Password',
                    hint: '••••••••',
                    isPassword: true,
                    prefix: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: newPasswordController,
                    label: 'New Password',
                    hint: 'At least 8 characters',
                    isPassword: true,
                    prefix: const Icon(Icons.lock_reset, size: 20, color: AppColors.textSecondary),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Repeat new password',
                    isPassword: true,
                    prefix: const Icon(Icons.lock_reset, size: 20, color: AppColors.textSecondary),
                    validator: (v) => Validators.validatePasswordConfirm(v, newPasswordController.text),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Update Password',
                    isLoading: auth.isLoading,
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(sheetContext);
                        final success = await auth.changePassword(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                          confirmPassword: confirmPasswordController.text,
                        );
                        if (!mounted) return;
                        nav.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? 'Password updated successfully!' : (auth.errorMessage ?? 'Password change failed'),
                            ),
                            backgroundColor: success ? AppColors.primaryDark : AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showServerConfigDialog(AuthProvider auth) {
    ServerConfigDialog.show(context);
  }

  void _showLanguageDialog(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold)),
          children: [
            RadioListTile<String>(
              title: const Text('English (Kenya)'),
              value: 'en',
              groupValue: auth.language,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) {
                  auth.setLanguage(val);
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Kiswahili'),
              value: 'sw',
              groupValue: auth.language,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) {
                  auth.setLanguage(val);
                  Navigator.pop(dialogContext);
                }
              },
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: CustomAppBar(
        title: 'Profile & Settings',
        showBack: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: user?.picture != null ? NetworkImage(user!.picture!) : null,
                          child: user?.picture == null
                              ? Text(
                                  user != null && user.firstName.isNotEmpty
                                      ? user.firstName[0].toUpperCase()
                                      : 'U',
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 32,
                                    color: AppColors.primaryDark,
                                  ),
                                )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName : 'Guest Shopper',
                      style: AppTextStyles.h2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email.isNotEmpty == true ? user!.email : 'No email linked',
                      style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: user?.isVerified == true ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user?.isVerified == true ? Icons.check_circle : Icons.warning_amber_rounded,
                                size: 14,
                                color: user?.isVerified == true ? const Color(0xFF15803D) : const Color(0xFFB45309),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user?.isVerified == true ? 'Verified Customer' : 'Unverified Email',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: user?.isVerified == true ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user != null && !user.isVerified && user.email.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EmailVerificationScreen(email: user.email),
                                ),
                              );
                            },
                            child: Text(
                              'Verify Now',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section: Personal Information
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: 'Legal Name',
                      subtitle: user?.fullName.isNotEmpty == true ? user!.fullName : 'Not provided',
                      onTap: () => _showEditProfileSheet(auth),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildInfoTile(
                      icon: Icons.alternate_email,
                      title: 'Username',
                      subtitle: user?.username.isNotEmpty == true ? '@${user!.username}' : 'Not set',
                      onTap: () => _showEditProfileSheet(auth),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Mobile Phone',
                      subtitle: user?.phone.isNotEmpty == true ? user!.phone : 'Not provided',
                      onTap: () => _showEditProfileSheet(auth),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section: App Preferences & Settings
              _buildSectionHeader('Preferences & Alerts'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      activeColor: AppColors.primary,
                      secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.slateDark),
                      title: const Text('Order Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Live status alerts for delivery updates', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      value: auth.orderNotifications,
                      onChanged: (val) {
                        auth.setOrderNotifications(val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order alerts ${val ? "enabled" : "disabled"}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile.adaptive(
                      activeColor: AppColors.primary,
                      secondary: const Icon(Icons.local_offer_outlined, color: AppColors.slateDark),
                      title: const Text('Promotions & Discounts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Receive discounts and weekly market offers', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      value: auth.promoNotifications,
                      onChanged: (val) {
                        auth.setPromoNotifications(val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Promotional alerts ${val ? "enabled" : "disabled"}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile.adaptive(
                      activeColor: AppColors.primary,
                      secondary: const Icon(Icons.sms_outlined, color: AppColors.slateDark),
                      title: const Text('SMS Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Receive order dispatch updates via SMS', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      value: auth.smsAlerts,
                      onChanged: (val) {
                        auth.setSmsAlerts(val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('SMS alerts ${val ? "enabled" : "disabled"}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.language_outlined, color: AppColors.slateDark),
                      title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(auth.language == 'sw' ? 'Kiswahili' : 'English (Kenya)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => _showLanguageDialog(auth),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section: Connectivity & Network
              _buildSectionHeader('Network & Server Settings'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined, color: AppColors.primaryDark),
                  title: const Text('Backend API URL', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    auth.currentApiUrl,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ),
                  onTap: () => _showServerConfigDialog(auth),
                ),
              ),

              const SizedBox(height: 24),

              // Section: Security
              _buildSectionHeader('Security & Account'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_reset_outlined, color: AppColors.slateDark),
                      title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => _showChangePasswordDialog(auth),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.error)),
                      onTap: () async {
                        final nav = Navigator.of(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure you want to sign out of your account?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await auth.logout();
                          if (!mounted) return;
                          nav.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginFlowScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.slateDark),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.slateDark),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
