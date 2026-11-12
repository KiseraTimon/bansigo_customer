// lib/features/recommendations/services/recommendation_service.dart

import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../models/recommendation_model.dart';

class RecommendationService {
  final ApiClient _apiClient;

  RecommendationService(this._apiClient);

  /// Fetch AI product recommendations (Apriori or FP-Growth randomly chosen by server)
  Future<List<RecommendationItemModel>> getRecommendations({
    int? productId,
    int limit = 6,
    String? algorithm,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (productId != null) {
        queryParams['product_id'] = productId;
      }
      if (algorithm != null) {
        queryParams['algorithm'] = algorithm;
      }

      final response = await _apiClient.get(
        ApiEndpoints.recommendations,
        queryParameters: queryParams,
      );

      if (response is List) {
        return response
            .map((item) => RecommendationItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      AppLogger.w('Failed to fetch recommendations: $e');
    }
    return [];
  }

  /// Track interaction event (impression, click, add_to_cart, helpful, unhelpful)
  Future<bool> trackEvent({
    required int productId,
    required String algorithm,
    required String eventType,
    String? context,
    String? sessionId,
    int? rating,
    String? feedbackText,
  }) async {
    try {
      final payload = <String, dynamic>{
        'product_id': productId,
        'algorithm': algorithm,
        'event_type': eventType,
        'context': context ?? 'home',
      };
      if (sessionId != null) payload['session_id'] = sessionId;
      if (rating != null) payload['rating'] = rating;
      if (feedbackText != null) payload['feedback_text'] = feedbackText;

      final res = await _apiClient.postJson(
        ApiEndpoints.recommendationTrack,
        payload,
      );
      return res is Map && res['success'] == true;
    } catch (e) {
      AppLogger.w('Failed to track recommendation event: $e');
      return false;
    }
  }

  /// Fetch performance & acceptance metrics comparison
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.recommendationStats);
      if (response is Map<String, dynamic>) {
        return response;
      }
    } catch (e) {
      AppLogger.w('Failed to fetch recommendation stats: $e');
    }
    return null;
  }
}
