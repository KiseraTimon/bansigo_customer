// lib/features/home/widgets/advert_banner_slider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/illustrations/vector_illustrations.dart';

class AdvertSlideData {
  final String title;
  final String subtitle;
  final String badgeText;
  final String ctaText;
  final List<Color> gradientColors;
  final Widget illustration;
  final VoidCallback? onTap;

  const AdvertSlideData({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.ctaText,
    required this.gradientColors,
    required this.illustration,
    this.onTap,
  });
}

class AdvertBannerSlider extends StatefulWidget {
  final ValueChanged<int>? onSlideTap;

  const AdvertBannerSlider({
    super.key,
    this.onSlideTap,
  });

  @override
  State<AdvertBannerSlider> createState() => _AdvertBannerSliderState();
}

class _AdvertBannerSliderState extends State<AdvertBannerSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final List<AdvertSlideData> _slides = const [
    AdvertSlideData(
      title: 'Fresh Farm Harvest',
      subtitle: 'Up to 30% OFF organic greens & local produce',
      badgeText: 'LIMITED DEAL',
      ctaText: 'Shop Fresh',
      gradientColors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
      illustration: AvocadoIllustration(size: 74),
    ),
    AdvertSlideData(
      title: 'Lightning Free Delivery',
      subtitle: 'Zero fee on your next 3 orders over KSh 1,200',
      badgeText: 'CODE: BANSIFREE',
      ctaText: 'Claim Now',
      gradientColors: [Color(0xFF4D7C0F), Color(0xFF84CC16)],
      illustration: DeliveryIllustration(size: 74),
    ),
    AdvertSlideData(
      title: 'Morning Bakery Delights',
      subtitle: 'Warm crusty artisan loaves & fresh dairy milk',
      badgeText: 'FRESH OVEN',
      ctaText: 'Explore',
      gradientColors: [Color(0xFFC2410C), Color(0xFFFB923C)],
      illustration: BreakfastIllustration(size: 74),
    ),
    AdvertSlideData(
      title: 'Weekend BBQ & Butchery',
      subtitle: 'Prime aged beef steaks, sausages & ocean fish',
      badgeText: 'SAVE 25%',
      ctaText: 'View Cuts',
      gradientColors: [Color(0xFF991B1B), Color(0xFFEF4444)],
      illustration: MeatFishIllustration(size: 74),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoTransition();
  }

  void _startAutoTransition() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 154,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () => widget.onSlideTap?.call(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: slide.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: slide.gradientColors.first.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background decorative circle glow
                        Positioned(
                          right: -10,
                          bottom: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),

                        // Text content on left
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      slide.badgeText,
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 9.5,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Title
                                  Text(
                                    slide.title,
                                    style: AppTextStyles.h2.copyWith(
                                      color: Colors.white,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),

                                  // Subtitle
                                  Text(
                                    slide.subtitle,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 11.5,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Action CTA Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          slide.ctaText,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.slateDark,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 12,
                                          color: AppColors.slateDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Vector illustration on right
                            Expanded(
                              flex: 4,
                              child: Center(
                                child: slide.illustration,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Animated Page Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
