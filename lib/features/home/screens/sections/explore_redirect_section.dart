// lib/features/home/screens/sections/explore_redirect_section.dart

import 'package:flutter/material.dart';
import '../../widgets/explore_redirect_card.dart';

class ExploreRedirectSection extends StatelessWidget {
  final VoidCallback onExploreTap;

  const ExploreRedirectSection({
    super.key,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return ExploreRedirectCard(
      onExploreTap: onExploreTap,
    );
  }
}
