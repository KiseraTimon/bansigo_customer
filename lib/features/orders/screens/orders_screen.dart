// lib/features/orders/screens/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/templates/screen_template.dart';
import '../../../shared/widgets/payment_prompt_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import 'sections/ongoing_cart_card.dart';
import 'sections/orders_empty_section.dart';
import 'sections/orders_tab_header.dart';
import 'sections/order_card_item.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback? onStartShopping;

  const OrdersScreen({super.key, this.onStartShopping});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  void _handleOrderHere() {
    if (widget.onStartShopping != null) {
      widget.onStartShopping!();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// Launch payment dialog to complete pending payment
  void _handlePayNow(CustomerOrderModel order) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userPhone = auth.currentUser?.phone ?? '0712345678';
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PaymentPromptDialog(
        orderId: order.id,
        orderNumber: order.orderNumber.isNotEmpty ? order.orderNumber : 'Order #${order.id}',
        phone: userPhone,
        orderService: orderProvider.service,
        onConfirmed: () {
          orderProvider.loadOrders();
          Navigator.of(dialogCtx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment confirmed! Order #${order.orderNumber} is now confirmed.'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  /// Cancel an order and release reserved items
  Future<void> _handleCancelOrder(CustomerOrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(
          'Are you sure you want to cancel Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}?\n\nReserved items will be returned to stock.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Order', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.cancelOrder(order.id, reason: 'Cancelled by customer');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id} has been cancelled.'
                : 'Failed to cancel order. Please try again.',
          ),
          backgroundColor: success ? const Color(0xFF475569) : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Edit order by loading its items into shopping cart
  Future<void> _handleEditOrder(CustomerOrderModel order) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Fetch order detail to get actual lines
    final detail = await orderProvider.fetchOrderDetail(order.id);
    final items = detail != null && detail['items'] is List ? detail['items'] as List : <dynamic>[];

    if (!mounted) return;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load order items for editing.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Order in Basket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(
          'Load ${items.length} items from Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id} into your cart to adjust quantities or add products.\n\nWould you like to cancel the previous pending order?',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel_dialog'),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'keep_and_copy'),
            child: const Text('Just Copy to Basket'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'cancel_and_edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Old & Edit in Basket'),
          ),
        ],
      ),
    );

    if (action == null || action == 'cancel_dialog' || !mounted) return;

    if (action == 'cancel_and_edit') {
      await orderProvider.cancelOrder(order.id, reason: 'Reopened by customer for editing');
    }

    cart.loadOrderItemsIntoCart(
      items: items,
      sessionName: 'Edit Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}',
      createDedicatedSession: true,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded ${items.length} items into basket for editing.'),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
      );
    }
  }

  /// Append order items to active ongoing cart
  Future<void> _handleAppendOrder(CustomerOrderModel order) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    final detail = await orderProvider.fetchOrderDetail(order.id);
    final items = detail != null && detail['items'] is List ? detail['items'] as List : <dynamic>[];

    if (!mounted) return;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load order items to append.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    cart.loadOrderItemsIntoCart(
      items: items,
      createDedicatedSession: false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appended ${items.length} items from Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id} to your active cart.'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showOrderDetails(BuildContext context, CustomerOrderModel order) {
    final isPending = order.status.toLowerCase() == 'pending_payment' ||
        order.paymentStatus.toLowerCase() == 'pending' ||
        order.paymentStatus.toLowerCase() == 'failed';
    final isCancellable = order.status.toLowerCase() == 'pending_payment' ||
        order.status.toLowerCase() == 'confirmed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPending ? const Color(0xFFB45309) : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildDetailRow('Date', '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
              _buildDetailRow('Fulfilment', order.fulfilmentType.toUpperCase()),
              _buildDetailRow('Payment Method', order.paymentMethod.toUpperCase()),
              _buildDetailRow('Payment Status', order.paymentStatus.toUpperCase()),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(
                    order.formattedTotal,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action buttons for pending payment orders
              if (isPending) ...[
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _handlePayNow(order);
                    },
                    icon: const Icon(Icons.payment_rounded, size: 18),
                    label: Text(
                      'Complete Payment (${order.formattedTotal})',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _handleEditOrder(order);
                        },
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: const Text('Edit in Basket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0284C7),
                          side: const BorderSide(color: Color(0xFFBAE6FD)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _handleAppendOrder(order);
                        },
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                        label: const Text('Append to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF16A34A),
                          side: const BorderSide(color: Color(0xFFBBF7D0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isCancellable) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _handleCancelOrder(order);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                      label: const Text('Cancel / Delete Order', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider?>(context);
    final ongoingCarts = cart?.activeSessionsWithItems ?? const [];

    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final activeTab = provider.activeTab;
        final orders = provider.currentOrders;
        final isLoading = provider.isLoading;

        final isOngoing = activeTab == OrderTabType.ongoing;
        final hasOngoingCarts = isOngoing && ongoingCarts.isNotEmpty;
        final isEmpty = isOngoing
            ? (!hasOngoingCarts && orders.isEmpty)
            : orders.isEmpty;

        return ScreenTemplate(
          isScrollable: false,
          header: SafeArea(
            bottom: false,
            child: OrdersTabHeader(
              activeTab: activeTab,
              onTabSelected: (tab) => provider.setTab(tab),
            ),
          ),
          body: isLoading && !hasOngoingCarts
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : isEmpty
                  ? OrdersEmptySection(
                      activeTab: activeTab,
                      onOrderHere: _handleOrderHere,
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => provider.loadOrders(),
                      child: ListView(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        children: [
                          // 1. Ongoing in-cart orders
                          if (isOngoing && hasOngoingCarts) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_cart_outlined, size: 16, color: Color(0xFFEA580C)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Active Shopping Carts (${ongoingCarts.length})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...ongoingCarts.map((c) => OngoingCartCard(session: c)),
                            if (orders.isNotEmpty) const SizedBox(height: 12),
                          ],

                          // 2. Submitted backend orders
                          if (orders.isNotEmpty) ...[
                            if (isOngoing && hasOngoingCarts)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                child: Text(
                                  'Submitted Orders',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ...orders.map(
                              (order) => OrderCardItem(
                                order: order,
                                onTap: () => _showOrderDetails(context, order),
                                onPayNow: () => _handlePayNow(order),
                                onEdit: () => _handleEditOrder(order),
                                onAppend: () => _handleAppendOrder(order),
                                onCancel: () => _handleCancelOrder(order),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
