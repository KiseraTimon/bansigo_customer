// lib/features/orders/screens/sections/order_card_item.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/order_model.dart';

class OrderCardItem extends StatelessWidget {
  final CustomerOrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onPayNow;
  final VoidCallback? onTrack;
  final VoidCallback? onEdit;
  final VoidCallback? onAppend;
  final VoidCallback? onCancel;
  final VoidCallback? onRate;

  const OrderCardItem({
    super.key,
    required this.order,
    this.onTap,
    this.onPayNow,
    this.onTrack,
    this.onEdit,
    this.onAppend,
    this.onCancel,
    this.onRate,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF16A34A);
      case 'preparing':
      case 'ready':
      case 'out_for_delivery':
        return const Color(0xFFEA580C);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }

  bool get isPendingPayment =>
      order.status.toLowerCase() == 'pending_payment' ||
      order.paymentStatus.toLowerCase() == 'pending' ||
      order.paymentStatus.toLowerCase() == 'failed';

  bool get isCancellable =>
      order.status.toLowerCase() == 'pending_payment' ||
      order.status.toLowerCase() == 'confirmed';

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPendingPayment ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
            width: isPendingPayment ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isPendingPayment
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyBold.copyWith(
                      fontSize: 14.5,
                      color: AppColors.slateDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  constraints: const BoxConstraints(maxWidth: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.replaceAll('_', ' ').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} • ${order.fulfilmentType.toUpperCase()} • ${order.paymentMethod.toUpperCase()}',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Amount',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  order.formattedTotal,
                  style: AppTextStyles.bodyBold.copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            if (!isPendingPayment &&
                order.fulfilmentType.toLowerCase() == 'delivery' &&
                order.status.toLowerCase() != 'cancelled' &&
                order.status.toLowerCase() != 'completed' &&
                onTrack != null) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTrack,
                  icon: const Icon(Icons.location_searching_rounded, size: 16),
                  label: const Text('Track Rider & Handover PIN', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2C59),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],

            if (order.status.toLowerCase() == 'completed' && onRate != null) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRate,
                  icon: const Icon(Icons.star_rate_rounded, size: 17, color: Color(0xFFF59E0B)),
                  label: Text(
                    order.fulfilmentType.toLowerCase() == 'delivery'
                        ? 'Rate Rider & Items'
                        : 'Rate Purchased Items',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: Color(0xFFBBF7D0)),
                    backgroundColor: const Color(0xFFF0FDF4),
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],

            if (isPendingPayment) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPayNow ?? onTap,
                      icon: const Icon(Icons.payment_rounded, size: 15),
                      label: const Text('Complete Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    tooltip: 'Order options',
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.more_horiz_rounded, size: 18, color: Color(0xFF475569)),
                    ),
                    onSelected: (val) {
                      switch (val) {
                        case 'pay':
                          onPayNow?.call();
                          break;
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'append':
                          onAppend?.call();
                          break;
                        case 'cancel':
                          onCancel?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF0284C7)),
                            SizedBox(width: 8),
                            Text('Edit in Basket', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'append',
                        child: Row(
                          children: [
                            Icon(Icons.add_shopping_cart_rounded, size: 18, color: Color(0xFF16A34A)),
                            SizedBox(width: 8),
                            Text('Append to Cart', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      if (isCancellable)
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Cancel Order', style: TextStyle(fontSize: 13, color: AppColors.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
