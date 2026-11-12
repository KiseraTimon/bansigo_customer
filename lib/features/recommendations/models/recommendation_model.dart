// lib/features/recommendations/models/recommendation_model.dart

import '../../home/models/product_model.dart';

class RecommendationItemModel {
  final ProductModel product;
  final String algorithm; // 'apriori' or 'fpgrowth'
  final double score;
  final String reason;
  final String recommendationTag;

  const RecommendationItemModel({
    required this.product,
    required this.algorithm,
    required this.score,
    required this.reason,
    this.recommendationTag = '⭐ Recommended',
  });

  factory RecommendationItemModel.fromJson(Map<String, dynamic> json) {
    final prodJson = json['product'] as Map<String, dynamic>? ?? {};
    return RecommendationItemModel(
      product: ProductModel.fromJson(prodJson),
      algorithm: json['algorithm']?.toString() ?? 'apriori',
      score: (json['score'] as num?)?.toDouble() ?? 1.0,
      reason: json['reason']?.toString() ?? 'Recommended for you',
      recommendationTag: json['recommendation_tag']?.toString() ?? '⭐ Recommended',
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'algorithm': algorithm,
        'score': score,
        'reason': reason,
        'recommendation_tag': recommendationTag,
      };
}
