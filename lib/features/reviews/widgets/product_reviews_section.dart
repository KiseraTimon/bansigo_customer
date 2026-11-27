// lib/features/reviews/widgets/product_reviews_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ProductReviewsSection extends StatefulWidget {
  final int? productId;
  final String productName;
  final void Function(double averageRating, int totalReviews)? onReviewsLoaded;

  const ProductReviewsSection({
    super.key,
    required this.productId,
    required this.productName,
    this.onReviewsLoaded,
  });

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  ProductReviewsSummaryModel? _summary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void didUpdateWidget(covariant ProductReviewsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _loadReviews();
    }
  }

  Future<void> _loadReviews() async {
    final pid = widget.productId;
    if (pid == null || pid <= 0) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      final api = context.read<ApiClient>();
      final summary = await ReviewService(api).getProductReviews(pid);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
      if (summary.averageRating != null) {
        widget.onReviewsLoaded?.call(summary.averageRating!, summary.totalReviews);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openWriteReviewSheet() async {
    final pid = widget.productId;
    if (pid == null || pid <= 0) return;

    final auth = context.read<AuthProvider?>();
    if (auth == null || !auth.isAuthenticated) {
      AppToast.show(
        context,
        'Please sign in to submit a product review.',
        type: AppToastType.warning,
      );
      return;
    }

    int selectedRating = 5;
    final commentCtrl = TextEditingController();
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                  const SizedBox(height: 16),
                  Text(
                    'Review ${widget.productName}',
                    style: AppTextStyles.h2.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to rate',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (idx) {
                      final star = idx + 1;
                      final active = star <= selectedRating;
                      return IconButton(
                        onPressed: () => setModalState(() => selectedRating = star),
                        icon: Icon(
                          active ? Icons.star_rounded : Icons.star_border_rounded,
                          color: active ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                          size: 34,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    maxLength: 600,
                    decoration: InputDecoration(
                      hintText: 'Share product freshness, packaging, or value feedback...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              try {
                                final api = context.read<ApiClient>();
                                await ReviewService(api).submitReview(
                                  targetType: 'product',
                                  productId: pid,
                                  rating: selectedRating,
                                  comment: commentCtrl.text,
                                );
                                if (ctx.mounted) Navigator.of(ctx).pop();
                                if (mounted) {
                                  AppToast.show(
                                    context,
                                    'Thank you! Your review has been saved.',
                                    type: AppToastType.success,
                                  );
                                  await _loadReviews();
                                }
                              } on ApiException catch (e) {
                                if (mounted) {
                                  AppToast.show(context, e.message, type: AppToastType.error);
                                }
                              } catch (e) {
                                if (mounted) {
                                  AppToast.show(context, 'Failed to submit review: $e', type: AppToastType.error);
                                }
                              } finally {
                                if (ctx.mounted) setModalState(() => isSubmitting = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    commentCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productId == null) {
      return const SizedBox.shrink();
    }

    final total = _summary?.totalReviews ?? 0;
    final avg = _summary?.averageRating;
    final reviews = _summary?.reviews ?? const <ReviewModel>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Reviews',
                    style: AppTextStyles.h2.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        avg != null
                            ? '${avg.toStringAsFixed(1)} ($total ${total == 1 ? 'review' : 'reviews'})'
                            : 'No reviews yet',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _openWriteReviewSheet,
                icon: const Icon(Icons.rate_review_outlined, size: 17),
                label: const Text('Write Review', style: TextStyle(fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading && _summary == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            )
          else if (reviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Be the first shopper to review this item.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            Column(
              children: reviews.take(6).map((rev) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                rev.customerName,
                                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13.5),
                              ),
                              if (rev.verifiedPurchase) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Verified Buyer',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rev.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 15,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (rev.comment != null && rev.comment!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          rev.comment!,
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF334155),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
