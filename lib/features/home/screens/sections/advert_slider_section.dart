// lib/features/home/screens/sections/advert_slider_section.dart

import 'package:flutter/material.dart';
import '../../widgets/advert_banner_slider.dart';

class AdvertSliderSection extends StatelessWidget {
  final ValueChanged<int>? onSlideTap;

  const AdvertSliderSection({
    super.key,
    this.onSlideTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdvertBannerSlider(
      onSlideTap: onSlideTap,
    );
  }
}
