// lib/features/auth/screens/verification/email_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/illustrations/vector_illustrations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../home/screens/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../auth_success_screen.dart';
import 'widgets/pin_code_input.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String _enteredCode = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onSendCode() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.requestEmailVerification();
    if (success && mounted) {
      setState(() => _currentStep = 1);
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _onVerifyCode() async {
    if (_enteredCode.length == 6) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.confirmEmailVerification(_enteredCode);
      if (success && mounted) {
        setState(() => _currentStep = 2);
        _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _currentStep < 2
          ? CustomAppBar(
              showBack: _currentStep > 0,
              onBack: () {
                if (_currentStep == 1) {
                  setState(() => _currentStep = 0);
                  _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  Navigator.of(context).maybePop();
                }
              },
              title: 'Email Verification',
            )
          : null,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildEmailStep(auth),
            _buildCodeStep(auth),
            _buildSuccessStep(),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: Email Confirmation & Send Code ---
  Widget _buildEmailStep(AuthProvider auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: MailIllustration(size: 100)),
                    const SizedBox(height: 20),
                    Text('Verify Your Email', style: AppTextStyles.h1),
                    const SizedBox(height: 6),
                    Text(
                      'To secure your account and receive order receipts, please verify your email address:',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 16),

                    // Email box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryLight, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_read_outlined, color: AppColors.primaryDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.email,
                              style: AppTextStyles.bodySemiBold.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(auth.errorMessage!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                    ],

                    const Spacer(),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Send Verification Code',
                      isLoading: auth.isLoading,
                      onPressed: _onSendCode,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Verify later',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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

  // --- STEP 2: 6-Digit PIN Code ---
  Widget _buildCodeStep(AuthProvider auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: MailIllustration(size: 85)),
                    const SizedBox(height: 16),
                    Text('Enter 6-Digit Code', style: AppTextStyles.h1),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.subtitle,
                        children: [
                          const TextSpan(text: 'We sent a verification code to '),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6 Digit PIN input
                    Center(
                      child: PinCodeInput(
                        length: 6,
                        onCompleted: (code) {
                          _enteredCode = code;
                          _onVerifyCode();
                        },
                        onChanged: (code) {
                          _enteredCode = code;
                        },
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          auth.errorMessage!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: auth.isLoading ? null : _onSendCode,
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
                      text: 'Verify Email',
                      isLoading: auth.isLoading,
                      onPressed: _enteredCode.length == 6 ? _onVerifyCode : null,
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

  // --- STEP 3: Success ---
  Widget _buildSuccessStep() {
    return AuthSuccessScreen(
      title: 'Email Verified!',
      subtitle: 'Your email has been confirmed. Your account is fully protected and ready for shopping.',
      buttonText: 'Start Shopping',
      onButtonPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      },
    );
  }
}
