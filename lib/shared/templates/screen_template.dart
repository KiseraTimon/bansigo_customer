// lib/shared/templates/screen_template.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable Screen Template for BansiGo customer screens.
///
/// Features:
/// - Consistent background ambient glow matching BansiGo branding
/// - Safe area management (top/bottom)
/// - Flexible scrollable or fixed body layout
/// - Optional header / app bar slot
/// - Floating overlay slot (e.g. mini-cart pill bar)
/// - Bottom navigation bar slot
/// - Built-in loading indicator overlay
///
/// Example Usage:
/// ```dart
/// class MyNewScreen extends StatelessWidget {
///   const MyNewScreen({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return ScreenTemplate(
///       header: const MyHeaderSection(),
///       sections: const [
///         MyHeroSection(),
///         MyListSection(),
///       ],
///       bottomNavigationBar: const MyBottomNav(),
///     );
///   }
/// }
/// ```
class ScreenTemplate extends StatelessWidget {
  /// Optional fixed top header (outside the scroll view, e.g. custom search/location bar).
  final Widget? header;

  /// Ordered list of sections to render inside the scrollable body.
  /// If [body] is provided, [sections] is ignored.
  final List<Widget>? sections;

  /// Custom non-section body. Overrides [sections].
  final Widget? body;

  /// Whether the body should be wrapped in a scroll view. Defaults to true.
  final bool isScrollable;

  /// Scroll physics for the scroll view. Defaults to BouncingScrollPhysics.
  final ScrollPhysics scrollPhysics;

  /// Padding applied around the scrollable content or body.
  final EdgeInsetsGeometry contentPadding;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Optional floating overlay (e.g., floating mini-cart pill bar).
  final Widget? floatingOverlay;

  /// Optional background color. Defaults to Colors.white.
  final Color backgroundColor;

  /// Whether to render the brand peach radial glow in the top-right corner. Defaults to true.
  final bool showAmbientGlow;

  /// Whether to show a full-screen loading spinner overlay.
  final bool isLoading;

  /// Refresh callback for pull-to-refresh functionality.
  final RefreshCallback? onRefresh;

  const ScreenTemplate({
    super.key,
    this.header,
    this.sections,
    this.body,
    this.isScrollable = true,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.contentPadding = EdgeInsets.zero,
    this.bottomNavigationBar,
    this.floatingOverlay,
    this.backgroundColor = Colors.white,
    this.showAmbientGlow = true,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (body != null) {
      content = body!;
    } else if (sections != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections!,
      );
    } else {
      content = const SizedBox.shrink();
    }

    if (isScrollable) {
      final effectivePhysics = onRefresh != null
          ? AlwaysScrollableScrollPhysics(parent: scrollPhysics)
          : scrollPhysics;

      content = SingleChildScrollView(
        physics: effectivePhysics,
        padding: contentPadding,
        child: content,
      );

      if (onRefresh != null) {
        content = RefreshIndicator(
          onRefresh: onRefresh!,
          color: AppColors.primary,
          child: content,
        );
      }
    } else {
      content = Padding(
        padding: contentPadding,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1. Brand Ambient Glow (top-right)
          if (showAmbientGlow)
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFEDD5).withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

          // 2. Main Layout
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (header != null) header!,
                Expanded(child: content),
              ],
            ),
          ),

          // 3. Floating Overlay (e.g. Mini-Cart)
          if (floatingOverlay != null) floatingOverlay!,

          // 4. Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
