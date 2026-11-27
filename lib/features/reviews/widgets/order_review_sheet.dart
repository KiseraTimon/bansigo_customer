// lib/features/reviews/widgets/order_review_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_toast.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class OrderReviewSheet extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const OrderReviewSheet({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  static Future<void> show(
    BuildContext context, {
    required int orderId,
    required String orderNumber,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => OrderReviewSheet(
        orderId: orderId,
        orderNumber: orderNumber,
      ),
    );
  }

  @override
  State<OrderReviewSheet> createState() => _OrderReviewSheetState();
}

class _OrderReviewSheetState extends State<OrderReviewSheet> {
  OrderReviewStatusModel? _status;
  bool _isLoading = true;
  bool _isSubmitting = false;

  int _deliveryRating = 5;
  final _deliveryCommentCtrl = TextEditingController();

  final Map<int, int> _productRatings = {};
  final Map<int, TextEditingController> _productCommentCtrls = {};

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _deliveryCommentCtrl.dispose();
    for (final ctrl in _productCommentCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiClient>();
      final status = await ReviewService(api).getOrderReviewStatus(widget.orderId);
      if (!mounted) return;
      if (status != null) {
        if (status.existingDeliveryReview != null) {
          _deliveryRating = status.existingDeliveryReview!.rating;
          _deliveryCommentCtrl.text = status.existingDeliveryReview!.comment ?? '';
        }
        for (final item in status.reviewableProducts) {
          _productRatings.putIfAbsent(
            item.productId,
            () => item.existingReview?.rating ?? 5,
          );
          _productCommentCtrls.putIfAbsent(
            item.productId,
            () => TextEditingController(text: item.existingReview?.comment ?? ''),
          );
        }
      }
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitDeliveryRating() async {
    final status = _status;
    if (status == null || !status.canReviewDelivery) return;
    setState(() => _isSubmitting = true);
    try {
      final api = context.read<ApiClient>();
      await ReviewService(api).submitReview(
        targetType: 'delivery',
        orderId: widget.orderId,
        riderId: status.riderId,
        rating: _deliveryRating,
        comment: _deliveryCommentCtrl.text,
      );
      if (!mounted) return;
      AppToast.show(context, 'Delivery & rider rating saved!', type: AppToastType.success);
      await _loadStatus();
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, type: AppToastType.error);
    } catch (e) {
      if (mounted) AppToast.show(context, 'Could not submit rating: $e', type: AppToastType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitProductRating(int productId) async {
    setState(() => _isSubmitting = true);
    try {
      final api = context.read<ApiClient>();
      await ReviewService(api).submitReview(
        targetType: 'product',
        orderId: widget.orderId,
        productId: productId,
        rating: _productRatings[productId] ?? 5,
        comment: _productCommentCtrls[productId]?.text,
      );
      if (!mounted) return;
      AppToast.show(context, 'Product review saved!', type: AppToastType.success);
      await _loadStatus();
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, type: AppToastType.error);
    } catch (e) {
      if (mounted) AppToast.show(context, 'Could not submit review: $e', type: AppToastType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarPicker(int rating, ValueChanged<int> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final star = i + 1;
        return IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(),
          onPressed: () => onChanged(star),
          icon: Icon(
            star <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 28,
            color: star <= rating ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rate Order #${widget.orderNumber}',
                  style: AppTextStyles.h2.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_status == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Reviews can be submitted once an order is completed.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_status!.canReviewDelivery) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.two_wheeler_rounded, color: AppColors.primaryDark, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Rider & Delivery${_status!.riderName != null ? ' • ${_status!.riderName}' : ''}',
                                      style: AppTextStyles.bodyBold.copyWith(fontSize: 14.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildStarPicker(
                                _deliveryRating,
                                (v) => setState(() => _deliveryRating = v),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _deliveryCommentCtrl,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: 'How was the delivery speed & rider service?',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitDeliveryRating,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    _status!.deliveryReviewed ? 'Update Rider Rating' : 'Submit Rider Rating',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_status!.reviewableProducts.isNotEmpty) ...[
                        Text(
                          'Items in This Order',
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: AppColors.slateDark),
                        ),
                        const SizedBox(height: 8),
                        ..._status!.reviewableProducts.map((item) {
                          final rating = _productRatings[item.productId] ?? 5;
                          final ctrl = _productCommentCtrls[item.productId]!;
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                _buildStarPicker(
                                  rating,
                                  (v) => setState(() => _productRatings[item.productId] = v),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: ctrl,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: 'Optional feedback on this item...',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _submitProductRating(item.productId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Text(
                                      item.reviewed ? 'Update Item Review' : 'Save Item Review',
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
