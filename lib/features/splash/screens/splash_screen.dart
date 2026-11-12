// lib/features/splash/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/illustrations/vector_illustrations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/screens/login/login_flow_screen.dart';
import '../widgets/onboarding_slide.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'type': 'brand',
      'title': 'BansiGo',
      'subtitle': 'Fresh groceries and daily essentials delivered directly to your doorstep in Migori.',
      'illustration': const GroceryBasketIllustration(size: 200),
    },
    {
      'type': 'recommendations',
      'title': 'Smart Recommendations',
      'subtitle': 'Intelligent shopping powered by AI. Get pantry suggestions curated specifically for your household.',
      'illustration': const RecommendationsIllustration(size: 190),
    },
    {
      'type': 'delivery',
      'title': 'Swift & Fresh Delivery',
      'subtitle': 'Fast dispatch from your favorite local markets straight to your door with real-time tracking.',
      'illustration': const DeliveryIllustration(size: 190),
    },
  ];

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginFlowScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar (Skip button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand small label when not on first slide
                  _currentPage > 0
                      ? Text('BansiGo', style: AppTextStyles.brandTitle.copyWith(fontSize: 18))
                      : const SizedBox(width: 40),
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return OnboardingSlide(
                    illustration: slide['illustration'] as Widget,
                    title: slide['title'] as String,
                    description: slide['subtitle'] as String,
                  );
                },
              ),
            ),

            // Indicator Dots & Navigation Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Next / Get Started button
                  AppButton(
                    text: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 8),

                  // Powered by Rapid Instruments (from inspo)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      'Powered by Rapid Instruments',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
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
