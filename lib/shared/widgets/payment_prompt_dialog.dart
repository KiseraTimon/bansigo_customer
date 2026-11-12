// lib/shared/widgets/payment_prompt_dialog.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../features/orders/services/order_service.dart';

class PaymentPromptDialog extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final String phone;
  final CustomerOrderService orderService;
  final VoidCallback onConfirmed;
  final bool autoTriggerStk;

  const PaymentPromptDialog({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.phone,
    required this.orderService,
    required this.onConfirmed,
    this.autoTriggerStk = true,
  });

  @override
  State<PaymentPromptDialog> createState() => _PaymentPromptDialogState();
}

class _PaymentPromptDialogState extends State<PaymentPromptDialog> {
  final _manualCodeCtrl = TextEditingController();
  late final TextEditingController _phoneCtrl;
  bool _isVerifyingManual = false;
  bool _isReinitiatingStk = false;
  String? _manualError;
  String? _stkMessage;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.phone);
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _manualCodeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final statusResp = await widget.orderService.checkPaymentStatus(widget.orderId);
      if (statusResp != null) {
        final status = statusResp['status']?.toString().toLowerCase();
        if (status == 'completed' || status == 'successful' || status == 'paid') {
          timer.cancel();
          if (mounted) widget.onConfirmed();
        }
      }
    });
  }

  Future<void> _handleReinitiateStk() async {
    final rawPhone = _phoneCtrl.text.trim();
    final normPhone = Validators.normalisePhone(rawPhone);
    if (normPhone == null || normPhone.isEmpty) {
      setState(() => _stkMessage = 'Please enter a valid Kenyan phone (e.g. 0712345678)');
      return;
    }

    setState(() {
      _isReinitiatingStk = true;
      _stkMessage = null;
    });

    try {
      await widget.orderService.initiateMpesaPayment(
        orderId: widget.orderId,
        phone: normPhone,
      );
      if (mounted) {
        setState(() {
          _isReinitiatingStk = false;
          _stkMessage = 'M-Pesa prompt resent to $normPhone!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isReinitiatingStk = false;
          _stkMessage = 'Failed to prompt: ${e.toString().replaceAll("Exception:", "").trim()}';
        });
      }
    }
  }

  Future<void> _handleManualCodeSubmit() async {
    final code = _manualCodeCtrl.text.trim();
    if (code.length < 6) {
      setState(() => _manualError = 'Please enter a valid M-Pesa receipt code');
      return;
    }

    setState(() {
      _isVerifyingManual = true;
      _manualError = null;
    });

    try {
      final res = await widget.orderService.confirmManualMpesa(
        orderId: widget.orderId,
        transactionCode: code,
      );
      final status = res['status']?.toString().toLowerCase();
      if (status == 'confirmed' || status == 'completed' || status == 'paid') {
        _statusTimer?.cancel();
        if (mounted) widget.onConfirmed();
      } else {
        setState(() {
          _isVerifyingManual = false;
          _manualError = 'Order status: $status. Verification pending.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifyingManual = false;
          _manualError = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'M-Pesa Payment',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slateDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Complete payment for ${widget.orderNumber.isNotEmpty ? widget.orderNumber : "Order #${widget.orderId}"}. Enter your M-Pesa PIN on your phone.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Re-prompt phone row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'M-Pesa Phone Number',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isReinitiatingStk ? null : _handleReinitiateStk,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isReinitiatingStk
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Resend Prompt', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (_stkMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(_stkMessage!, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              // Fallback Section: Manual Code Entry
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.slateMedium),
                        const SizedBox(width: 6),
                        Text(
                          'Paid but not confirmed automatically?',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.slateDark,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your M-Pesa transaction code from Safaricom SMS:',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _manualCodeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'e.g. QA12345678',
                        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    if (_manualError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _manualError!,
                        style: const TextStyle(color: AppColors.error, fontSize: 11.5),
                      ),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isVerifyingManual ? null : _handleManualCodeSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: _isVerifyingManual
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Verify & Confirm Payment',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  _statusTimer?.cancel();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close / Pay Later',
                  style: TextStyle(color: AppColors.slateMedium, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
