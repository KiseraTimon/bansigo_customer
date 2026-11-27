// lib/features/reviews/models/review_model.dart

class ReviewModel {
  final int id;
  final String customerName;
  final String targetType;
  final int? orderId;
  final String? orderNumber;
  final int? productId;
  final String? productName;
  final int? riderId;
  final String? riderName;
  final int rating;
  final String? comment;
  final String? sentiment;
  final bool isPublished;
  final bool verifiedPurchase;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.customerName,
    required this.targetType,
    this.orderId,
    this.orderNumber,
    this.productId,
    this.productName,
    this.riderId,
    this.riderName,
    required this.rating,
    this.comment,
    this.sentiment,
    this.isPublished = true,
    this.verifiedPurchase = false,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerName: json['customer_name']?.toString() ?? 'Verified Shopper',
      targetType: json['target_type']?.toString() ?? 'product',
      orderId: (json['order_id'] as num?)?.toInt(),
      orderNumber: json['order_number']?.toString(),
      productId: (json['product_id'] as num?)?.toInt(),
      productName: json['product_name']?.toString(),
      riderId: (json['rider_id'] as num?)?.toInt(),
      riderName: json['rider_name']?.toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment']?.toString(),
      sentiment: json['sentiment']?.toString(),
      isPublished: json['is_published'] as bool? ?? true,
      verifiedPurchase: json['verified_purchase'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class ProductReviewsSummaryModel {
  final int productId;
  final double? averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  const ProductReviewsSummaryModel({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  factory ProductReviewsSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'] as List? ?? const [];
    return ProductReviewsSummaryModel(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      averageRating: double.tryParse(json['average_rating']?.toString() ?? ''),
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      reviews: rawReviews
          .whereType<Map>()
          .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class OrderProductReviewItem {
  final int productId;
  final String productName;
  final bool reviewed;
  final ReviewModel? existingReview;

  const OrderProductReviewItem({
    required this.productId,
    required this.productName,
    required this.reviewed,
    this.existingReview,
  });

  factory OrderProductReviewItem.fromJson(Map<String, dynamic> json) {
    return OrderProductReviewItem(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name']?.toString() ?? 'Item',
      reviewed: json['reviewed'] as bool? ?? false,
      existingReview: json['existing_review'] is Map
          ? ReviewModel.fromJson(Map<String, dynamic>.from(json['existing_review'] as Map))
          : null,
    );
  }
}

class OrderReviewStatusModel {
  final int orderId;
  final String orderNumber;
  final bool canReviewDelivery;
  final int? riderId;
  final String? riderName;
  final bool deliveryReviewed;
  final ReviewModel? existingDeliveryReview;
  final List<OrderProductReviewItem> reviewableProducts;

  const OrderReviewStatusModel({
    required this.orderId,
    required this.orderNumber,
    required this.canReviewDelivery,
    this.riderId,
    this.riderName,
    required this.deliveryReviewed,
    this.existingDeliveryReview,
    required this.reviewableProducts,
  });

  factory OrderReviewStatusModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['reviewable_products'] as List? ?? const [];
    return OrderReviewStatusModel(
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      canReviewDelivery: json['can_review_delivery'] as bool? ?? false,
      riderId: (json['rider_id'] as num?)?.toInt(),
      riderName: json['rider_name']?.toString(),
      deliveryReviewed: json['delivery_reviewed'] as bool? ?? false,
      existingDeliveryReview: json['existing_delivery_review'] is Map
          ? ReviewModel.fromJson(Map<String, dynamic>.from(json['existing_delivery_review'] as Map))
          : null,
      reviewableProducts: rawItems
          .whereType<Map>()
          .map((e) => OrderProductReviewItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
