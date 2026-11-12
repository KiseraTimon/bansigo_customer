// lib/features/home/models/category_model.dart

import 'package:flutter/widgets.dart';

class CategoryItem {
  final String id;
  final String title;
  final Widget illustration;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.illustration,
  });
}
