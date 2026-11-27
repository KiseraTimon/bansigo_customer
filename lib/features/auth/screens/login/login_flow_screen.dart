// lib/features/auth/screens/login/login_flow_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/illustrations/vector_illustrations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/phone_completion_dialog.dart';
import '../../../../shared/widgets/server_config_dialog.dart';
import '../../../../shared/widgets/social_auth_button.dart';
import '../../../home/screens/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../password_reset/password_reset_flow_screen.dart';
import '../register/register_flow_screen.dart';

import '../../../../shared/widgets/app_toast.dart';
class LoginFlowScreen extends StatefulWidget {
  const LoginFlowScreen({super.key});

  @override
  State<LoginFlowScreen> createState() => _LoginFlowScreenState();
}

class _LoginFlowScreenState extends State<LoginFlowScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _identifierFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onContinueIdentifier() {
    if (_identifierFormKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.setLoginIdentifier(_identifierController.text.trim());
      setState(() {
        _currentStep = 1;
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onSignIn() async {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.executeLogin(_passwordController.text);
      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
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
      AppToast.show(context, result.errorMessage!, type: AppToastType.error);
    }
  }

  Future<void> _onGoogleSignIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.signInWithGoogle();
    await _handleSocialResult(result);
  }

  Future<void> _onFacebookSignIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.signInWithFacebook();
    await _handleSocialResult(result);
  }

  void _onBack() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
        title: _currentStep == 1 ? 'Enter Password' : null,
        actions: [
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.dns_outlined, color: AppColors.slateDark, size: 22),
            onPressed: () => ServerConfigDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildUsernameStep(auth),
            _buildPasswordStep(auth),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: Username / Identifier & Social Logins ---
  Widget _buildUsernameStep(AuthProvider auth) {
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
                    // Illustration & Title
                    const Center(
                      child: GroceryBasketIllustration(size: 80),
                    ),
                    const SizedBox(height: 12),
                    Text('Welcome Back', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in using your account or social credentials',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 16),

                    // Social Auth Buttons (Google & Facebook)
                    SocialAuthButton(
                      provider: SocialProvider.google,
                      isLoading: auth.isSocialLoading,
                      onPressed: _onGoogleSignIn,
                    ),
                    SocialAuthButton(
                      provider: SocialProvider.facebook,
                      isLoading: auth.isSocialLoading,
                      onPressed: _onFacebookSignIn,
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('or with account', style: AppTextStyles.tiny),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),
                    ),

                    // Identifier Form
                    Form(
                      key: _identifierFormKey,
                      child: AppTextField(
                        controller: _identifierController,
                        label: 'Username or Email',
                        hint: 'e.g. john_doe or john@example.com',
                        prefix: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onContinueIdentifier(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your username or email';
                          }
                          return null;
                        },
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 10),
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

                    // Continue button
                    AppButton(
                      text: 'Continue',
                      onPressed: _onContinueIdentifier,
                    ),
                    const SizedBox(height: 12),

                    // Sign up redirect
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: AppTextStyles.caption),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterFlowScreen()),
                              );
                            },
                            child: Text(
                              'Sign Up',
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

  // --- STEP 2: Password ---
  Widget _buildPasswordStep(AuthProvider auth) {
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
                    const Center(
                      child: SecurityIllustration(size: 80),
                    ),
                    const SizedBox(height: 16),
                    Text('Enter Password', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Text(
                      'Signing in as: ${_identifierController.text}',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Form
                    Form(
                      key: _passwordFormKey,
                      child: AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        isPassword: true,
                        autofocus: true,
                        prefix: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onSignIn(),
                        validator: Validators.validatePassword,
                      ),
                    ),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PasswordResetFlowScreen()),
                          );
                        },
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 8),
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

                    // Sign In Submit Button
                    AppButton(
                      text: 'Sign In',
                      isLoading: auth.isLoading,
                      onPressed: _onSignIn,
                    ),
                    const SizedBox(height: 12),

                    // Switch user link
                    Center(
                      child: TextButton(
                        onPressed: _onBack,
                        child: Text(
                          'Switch account',
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
}
