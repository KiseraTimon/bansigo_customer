// lib/features/recommendations/providers/recommendation_provider.dart

import 'package:flutter/foundation.dart';
import '../../../core/utils/app_logger.dart';
import '../models/recommendation_model.dart';
import '../services/recommendation_service.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _service;

  List<RecommendationItemModel> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  final Set<int> _trackedImpressions = {};

  RecommendationProvider(this._service) {
    loadRecommendations();
  }

  List<RecommendationItemModel> get recommendations => List.unmodifiable(_recommendations);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecommendations({int? targetProductId, int limit = 6}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _service.getRecommendations(
        productId: targetProductId,
        limit: limit,
      );
    } catch (e) {
      AppLogger.e('RecommendationProvider error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Track impression when recommendation card becomes visible
  void trackImpression(RecommendationItemModel item, [String context = 'home']) {
    final pid = int.tryParse(item.product.id) ?? 0;
    if (pid <= 0 || _trackedImpressions.contains(pid)) return;

    _trackedImpressions.add(pid);
    _service.trackEvent(
      productId: pid,
      algorithm: item.algorithm,
      eventType: 'impression',
      context: context,
    );
  }

  /// Track when recommendation card is clicked
  void trackClick(RecommendationItemModel item, [String context = 'home']) {
    final pid = int.tryParse(item.product.id) ?? 0;
    if (pid <= 0) return;

    _service.trackEvent(
      productId: pid,
      algorithm: item.algorithm,
      eventType: 'click',
      context: context,
    );
  }

  /// Track when recommended product is added to cart
  void trackAddToCart(RecommendationItemModel item, [String context = 'home']) {
    final pid = int.tryParse(item.product.id) ?? 0;
    if (pid <= 0) return;

    _service.trackEvent(
      productId: pid,
      algorithm: item.algorithm,
      eventType: 'add_to_cart',
      context: context,
    );
  }

  /// Track user feedback (helpful / unhelpful / rating) to study usability
  Future<bool> trackFeedback(
    RecommendationItemModel item,
    bool isHelpful, {
    int? rating,
    String? feedbackText,
    String context = 'home',
  }) async {
    final pid = int.tryParse(item.product.id) ?? 0;
    if (pid <= 0) return false;

    return await _service.trackEvent(
      productId: pid,
      algorithm: item.algorithm,
      eventType: isHelpful ? 'helpful' : 'unhelpful',
      context: context,
      rating: rating,
      feedbackText: feedbackText,
    );
  }
}
