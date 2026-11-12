// lib/features/auth/screens/register/register_flow_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/phone_completion_dialog.dart';
import '../../../../shared/widgets/server_config_dialog.dart';
import '../../../../shared/widgets/social_auth_button.dart';
import '../../../../shared/widgets/step_progress_bar.dart';
import '../../../home/screens/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../verification/email_verification_screen.dart';

class RegisterFlowScreen extends StatefulWidget {
  const RegisterFlowScreen({super.key});

  @override
  State<RegisterFlowScreen> createState() => _RegisterFlowScreenState();
}

class _RegisterFlowScreenState extends State<RegisterFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1 Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final _step1FormKey = GlobalKey<FormState>();

  // Step 2 Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final _step2FormKey = GlobalKey<FormState>();

  // Step 3 Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _step3FormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onStep1Next() {
    if (_step1FormKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.setRegisterNames(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );
      setState(() => _currentStep = 1);
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onStep2Next() {
    if (_step2FormKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final rawPhone = _phoneController.text.trim();
      final normalised = Validators.normalisePhone(rawPhone) ?? rawPhone;
      auth.setRegisterContact(
        email: _emailController.text.trim(),
        phone: normalised,
        username: _usernameController.text.trim(),
      );
      setState(() => _currentStep = 2);
      _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _onStep3Submit() async {
    if (_step3FormKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.executeRegister(
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
      );

      if (success && mounted) {
        // Navigate to email verification screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleSocialResult(SocialAuthResult result) async {
    if (!mounted || result.cancelled) return;

    if (result.success) {
      if (result.requiresPhone) {
        await PhoneCompletionDialog.show(context);
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else if (result.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _onGoogleSignUp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.signInWithGoogle();
    await _handleSocialResult(result);
  }

  Future<void> _onFacebookSignUp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.signInWithFacebook();
    await _handleSocialResult(result);
  }

  void _onBack() {
    if (_currentStep > 0) {
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
      appBar: CustomAppBar(
        showBack: true,
        onBack: _onBack,
        title: 'Step ${_currentStep + 1} of 3',
        actions: [
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.dns_outlined, color: AppColors.slateDark, size: 22),
            onPressed: () => ServerConfigDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                  _buildStep1Names(auth),
                  _buildStep2Contact(auth),
                  _buildStep3Passwords(auth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: First Name & Last Name + Social Auth ---
  Widget _buildStep1Names(AuthProvider auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Account', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text('Choose social sign-up or enter your names', style: AppTextStyles.subtitle),
                    const SizedBox(height: 14),

                    // Social Auth Buttons on Step 1
                    SocialAuthButton(
                      provider: SocialProvider.google,
                      isLoading: auth.isSocialLoading,
                      onPressed: _onGoogleSignUp,
                    ),
                    SocialAuthButton(
                      provider: SocialProvider.facebook,
                      isLoading: auth.isSocialLoading,
                      onPressed: _onFacebookSignUp,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('or register with email', style: AppTextStyles.tiny),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),
                    ),

                    Form(
                      key: _step1FormKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            hint: 'e.g. Samuel',
                            prefix: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                            validator: (v) => Validators.validateName(v, fieldName: 'First name'),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            hint: 'e.g. Ochieng',
                            prefix: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onStep1Next(),
                            validator: (v) => Validators.validateName(v, fieldName: 'Last name'),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Next',
                      onPressed: _onStep1Next,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: AppTextStyles.caption),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(
                              'Sign In',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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

  // --- STEP 2: Email & Phone ---
  Widget _buildStep2Contact(AuthProvider auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact Details', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text(
                      'We will use this to confirm orders and deliveries',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 16),

                    Form(
                      key: _step2FormKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'samuel@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefix: const Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _phoneController,
                            label: 'Kenyan Mobile Number',
                            hint: '0712345678 or +2547...',
                            keyboardType: TextInputType.phone,
                            prefix: Container(
                              width: 72,
                              alignment: Alignment.center,
                              child: Text(
                                '🇰🇪 +254',
                                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
                              ),
                            ),
                            validator: Validators.validatePhone,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: _usernameController,
                            label: 'Username (Optional)',
                            hint: 'e.g. samuel_ke',
                            prefix: const Icon(Icons.alternate_email, size: 20, color: AppColors.textSecondary),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onStep2Next(),
                            validator: (v) => Validators.validateUsername(v, required: false),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Next',
                      onPressed: _onStep2Next,
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

  // --- STEP 3: Password & Confirm Password ---
  Widget _buildStep3Passwords(AuthProvider auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Password', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a secure password of at least 8 characters',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _step3FormKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'At least 8 characters',
                            isPassword: true,
                            prefix: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Repeat your password',
                            isPassword: true,
                            prefix: const Icon(Icons.lock_reset, size: 20, color: AppColors.textSecondary),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onStep3Submit(),
                            validator: (v) => Validators.validatePasswordConfirm(v, _passwordController.text),
                          ),
                        ],
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: AppTextStyles.caption.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Create Account',
                      isLoading: auth.isLoading,
                      onPressed: _onStep3Submit,
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
}
