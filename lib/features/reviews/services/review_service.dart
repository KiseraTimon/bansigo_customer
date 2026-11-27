// lib/features/reviews/services/review_service.dart

import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../models/review_model.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService(this._apiClient);

  Future<ProductReviewsSummaryModel> getProductReviews(int productId) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.productReviews(productId));
      if (res is Map<String, dynamic>) {
        return ProductReviewsSummaryModel.fromJson(res);
      }
      if (res is Map) {
        return ProductReviewsSummaryModel.fromJson(Map<String, dynamic>.from(res));
      }
    } catch (e) {
      AppLogger.w('Failed to fetch product reviews ($productId): $e');
    }
    return ProductReviewsSummaryModel(
      productId: productId,
      averageRating: null,
      totalReviews: 0,
      reviews: const [],
    );
  }

  Future<OrderReviewStatusModel?> getOrderReviewStatus(int orderId) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.orderReviews(orderId));
      if (res is Map<String, dynamic>) {
        return OrderReviewStatusModel.fromJson(res);
      }
      if (res is Map) {
        return OrderReviewStatusModel.fromJson(Map<String, dynamic>.from(res));
      }
    } catch (e) {
      AppLogger.w('Failed to fetch order review status ($orderId): $e');
    }
    return null;
  }

  Future<ReviewModel> submitReview({
    required String targetType,
    required int rating,
    String? comment,
    int? orderId,
    int? productId,
    int? riderId,
  }) async {
    final payload = <String, dynamic>{
      'target_type': targetType,
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (riderId != null) 'rider_id': riderId,
    };
    final res = await _apiClient.postJson(ApiEndpoints.reviews, payload);
    if (res is Map<String, dynamic>) {
      return ReviewModel.fromJson(res);
    }
    return ReviewModel.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<List<ReviewModel>> getMyReviews() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.myReviews);
      if (res is List) {
        return res
            .whereType<Map>()
            .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      AppLogger.w('Failed to fetch my reviews: $e');
    }
    return [];
  }
}
