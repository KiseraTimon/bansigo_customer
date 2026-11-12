// lib/features/checkout/screens/checkout_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/templates/screen_template.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/email_verification_banner.dart';
import '../../../shared/widgets/payment_prompt_dialog.dart';
import '../../../shared/widgets/product_image_widget.dart';
import '../../auth/screens/verification/email_verification_screen.dart';
import '../../address/providers/address_provider.dart';
import '../../address/screens/address_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login/login_flow_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../orders/services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _manualCodeController = TextEditingController();

  bool _isPlacingOrder = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userPhone = auth.currentUser?.phone;
    if (userPhone != null && userPhone.isNotEmpty) {
      _phoneController.text = userPhone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _noteController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleProceedToPay() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to place your order'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Sign In',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginFlowScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    if (auth.currentUser?.isVerified == false) {
      _showEmailVerificationRequiredDialog(context, auth.currentUser?.email ?? '');
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your basket is empty!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final selectedAddress = addressProvider.selectedAddress;
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a delivery address first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an M-Pesa phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final normPhone = Validators.normalisePhone(rawPhone);
    if (normPhone == null || normPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Kenyan phone number (e.g. 0712345678)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
      _errorMessage = null;
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final orderService = CustomerOrderService(apiClient);

      // 1. Prepare items payload
      final itemsPayload = cart.items.map((item) {
        final pid = int.tryParse(item.product.id) ?? 1;
        return {
          'product_id': pid,
          'quantity': item.quantity,
        };
      }).toList();

      int finalAddressId = selectedAddress.id;
      if (finalAddressId <= 0) {
        try {
          final created = await addressProvider.service.createAddress(selectedAddress);
          finalAddressId = created.id;
          addressProvider.selectAddress(created);
        } catch (_) {}
      }

      // 2. Call checkout endpoint
      final orderResult = await orderService.checkout(
        items: itemsPayload,
        addressId: finalAddressId,
        customerNote: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        fulfilmentType: 'delivery',
        paymentMethod: 'mpesa',
      );

      final orderId = (orderResult['id'] as num?)?.toInt();
      final orderNumber = orderResult['order_number']?.toString() ?? 'Order #$orderId';

      if (orderId == null) {
        throw ApiException('Failed to create order on server.');
      }

      // 3. Initiate M-Pesa STK Push
      await orderService.initiateMpesaPayment(
        orderId: orderId,
        phone: normPhone,
      );

      if (mounted) {
        setState(() => _isPlacingOrder = false);
        _showPaymentPromptDialog(
          orderId: orderId,
          orderNumber: orderNumber,
          phone: normPhone,
          orderService: orderService,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to place order. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEmailVerificationRequiredDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_unread_outlined, color: Color(0xFFD97706)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Verify Your Email',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Email verification is required before placing orders.\n\nPlease verify your email ($email) to secure your account and proceed with this order.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmailVerificationScreen(email: email),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Verify Email Now'),
          ),
        ],
      ),
    );
  }

  void _showPaymentPromptDialog({
    required int orderId,
    required String orderNumber,
    required String phone,
    required CustomerOrderService orderService,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PaymentPromptDialog(
        orderId: orderId,
        orderNumber: orderNumber,
        phone: phone,
        orderService: orderService,
        onConfirmed: () {
          final cart = Provider.of<CartProvider>(context, listen: false);
          cart.checkoutCompleted();
          final orderProvider = Provider.of<OrderProvider>(context, listen: false);
          orderProvider.loadOrders();
          Navigator.of(dialogCtx).pop(); // dismiss modal
          Navigator.of(context).pop(); // dismiss checkout screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment confirmed! Order $orderNumber has been placed.'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final selectedAddress = addressProvider.selectedAddress;

    const deliveryFee = 50.0;
    final totalPayable = cart.subtotal + deliveryFee;

    return ScreenTemplate(
      isScrollable: true,
      header: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.slateDark),
                splashRadius: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Checkout',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateDark,
                ),
              ),
            ],
          ),
        ),
      ),
      body: cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 40,
                        color: AppColors.slateMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your basket is empty',
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse our fresh supermarket aisles to add items.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EmailVerificationBanner(),
                  // 1. Delivery Address Card
                  _buildSectionHeader('Delivery Destination', Icons.location_on_rounded),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.home_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedAddress?.label ?? 'No address selected',
                                    style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    selectedAddress != null
                                        ? '${selectedAddress.streetAddress}, ${selectedAddress.area}'
                                        : 'Tap below to select or add address',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AddressScreen()),
                                );
                              },
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (addressProvider.isFarApart) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFCD34D)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFB45309)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Selected address is outside standard 7km delivery coverage.',
                                    style: AppTextStyles.caption.copyWith(
                                      color: const Color(0xFFB45309),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Items in Basket
                  _buildSectionHeader('Basket Items (${cart.totalQuantity})', Icons.shopping_bag_rounded),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Color(0xFFF1F5F9),
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ProductImageWidget(
                                product: item.product,
                                width: 52,
                                height: 52,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.product.formattedPrice} • ${item.product.unit}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => cart.decrementItem(item.product.id),
                                    icon: const Icon(Icons.remove_circle_outline_rounded),
                                    iconSize: 22,
                                    color: AppColors.slateMedium,
                                    splashRadius: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      '${item.quantity}',
                                      style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => cart.addItem(item.product),
                                    icon: const Icon(Icons.add_circle_rounded),
                                    iconSize: 22,
                                    color: AppColors.primary,
                                    splashRadius: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Delivery Instructions / Note
                  _buildSectionHeader('Delivery Instructions (Optional)', Icons.notes_rounded),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Ring gate bell, leave at reception...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
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
                  const SizedBox(height: 20),

                  // 4. M-Pesa Phone Number
                  _buildSectionHeader('M-Pesa Payment Phone', Icons.phone_android_rounded),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'M-PESA',
                                style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instant STK Prompt',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
                            hintText: '0712345678 or +254712345678',
                            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Bill Summary Card
                  _buildSectionHeader('Bill Summary', Icons.receipt_long_rounded),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildBillRow('Items Subtotal', cart.formattedSubtotal),
                        const SizedBox(height: 8),
                        _buildBillRow('Delivery Fee', 'KES ${deliveryFee.toStringAsFixed(2)}'),
                        const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
                        _buildBillRow(
                          'Total Payable',
                          'KES ${totalPayable.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Proceed to Pay Button
                  AppButton(
                    text: _isPlacingOrder
                        ? 'Prompting Phone...'
                        : 'Pay KES ${totalPayable.toStringAsFixed(2)} via M-Pesa',
                    icon: Icons.lock_outline_rounded,
                    isLoading: _isPlacingOrder,
                    onPressed: _isPlacingOrder ? null : _handleProceedToPay,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.h2.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.slateDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.h2.copyWith(fontSize: 15, fontWeight: FontWeight.w800)
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13.5),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.h2.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                )
              : AppTextStyles.bodySemiBold.copyWith(fontSize: 13.5),
        ),
      ],
    );
  }
}

