// lib/features/auth/screens/password_reset/password_reset_flow_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/illustrations/vector_illustrations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/step_progress_bar.dart';
import '../../providers/auth_provider.dart';
import '../auth_success_screen.dart';
import '../login/login_flow_screen.dart';
import '../verification/widgets/pin_code_input.dart';

class PasswordResetFlowScreen extends StatefulWidget {
  const PasswordResetFlowScreen({super.key});

  @override
  State<PasswordResetFlowScreen> createState() => _PasswordResetFlowScreenState();
}

class _PasswordResetFlowScreenState extends State<PasswordResetFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  final TextEditingController _emailController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();

  // Step 2
  String _resetCode = '';

  // Step 3
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSendEmail() async {
    if (_emailFormKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.requestPasswordReset(_emailController.text.trim());
      if (success && mounted) {
        setState(() => _currentStep = 1);
        _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void _onCodeSubmitted() {
    if (_resetCode.length == 6) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.setResetCode(_resetCode);
      setState(() => _currentStep = 2);
      _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _onSubmitNewPassword() async {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.confirmPasswordReset(
        newPassword: _newPasswordController.text,
        newPasswordConfirm: _confirmPasswordController.text,
      );
      if (success && mounted) {
        setState(() => _currentStep = 3);
        _pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void _onBack() {
    if (_currentStep > 0 && _currentStep < 3) {
      setState(() => _currentStep -= 1);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _currentStep < 3
          ? CustomAppBar(
              showBack: true,
              onBack: _onBack,
              title: 'Reset Password',
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep < 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: StepProgressBar(
                  totalSteps: 3,
                  currentStep: _currentStep,
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Email(auth),
                  _buildStep2Code(auth),
                  _buildStep3NewPassword(auth),
                  _buildStep4Success(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: Enter Email ---
  Widget _buildStep1Email(AuthProvider auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: SecurityIllustration(size: 85)),
                    const SizedBox(height: 16),
                    Text('Forgot Password?', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your registered email address and we will send you a reset code.',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _emailFormKey,
                      child: AppTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'your.email@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefix: const Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onSendEmail(),
                        validator: Validators.validateEmail,
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(auth.errorMessage!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                    ],

                    const Spacer(),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Send Reset Code',
                      isLoading: auth.isLoading,
                      onPressed: _onSendEmail,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Back to Sign In',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- STEP 2: Enter PIN ---
  Widget _buildStep2Code(AuthProvider auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: MailIllustration(size: 85)),
                    const SizedBox(height: 16),
                    Text('Enter Reset Code', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.subtitle,
                        children: [
                          const TextSpan(text: 'We sent a 6-digit code to '),
                          TextSpan(
                            text: _emailController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: PinCodeInput(
                        length: 6,
                        onCompleted: (code) {
                          _resetCode = code;
                          _onCodeSubmitted();
                        },
                        onChanged: (code) {
                          _resetCode = code;
                        },
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          auth.errorMessage!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: auth.isLoading ? null : _onSendEmail,
                        child: Text(
                          "Didn't receive code? Resend",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Continue',
                      onPressed: _resetCode.length == 6 ? _onCodeSubmitted : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- STEP 3: Enter New Password ---
  Widget _buildStep3NewPassword(AuthProvider auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: SecurityIllustration(size: 85)),
                    const SizedBox(height: 16),
                    Text('New Password', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a strong password to protect your account',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _newPasswordController,
                            label: 'New Password',
                            hint: 'At least 8 characters',
                            isPassword: true,
                            prefix: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm New Password',
                            hint: 'Repeat your new password',
                            isPassword: true,
                            prefix: const Icon(Icons.lock_reset, size: 20, color: AppColors.textSecondary),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onSubmitNewPassword(),
                            validator: (v) => Validators.validatePasswordConfirm(v, _newPasswordController.text),
                          ),
                        ],
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],

                    const Spacer(),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Reset Password',
                      isLoading: auth.isLoading,
                      onPressed: _onSubmitNewPassword,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- STEP 4: Success ---
  Widget _buildStep4Success() {
    return AuthSuccessScreen(
      title: 'Password Updated!',
      subtitle: 'Your password has been changed successfully. You can now sign in with your new credentials.',
      buttonText: 'Sign In Now',
      onButtonPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginFlowScreen()),
          (route) => false,
        );
      },
    );
  }
}
