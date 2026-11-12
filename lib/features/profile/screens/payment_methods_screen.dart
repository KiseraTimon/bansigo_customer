// lib/features/profile/screens/payment_methods_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final String _selectedMethod = 'mpesa';
  late final TextEditingController _mpesaPhoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final phone = auth.currentUser?.phone;
    _mpesaPhoneController = TextEditingController(
      text: phone != null && phone.trim().isNotEmpty ? phone.trim() : '',
    );
  }

  @override
  void dispose() {
    _mpesaPhoneController.dispose();
    super.dispose();
  }

  void _savePaymentPreference() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment preferences updated successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Methods',
          style: AppTextStyles.h1.copyWith(fontSize: 19),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Default Payment',
                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose how you would like to settle your grocery orders at BansiGo.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              // 1. M-Pesa Express Option (Active)
              _buildPaymentCard(
                id: 'mpesa',
                title: 'M-Pesa (Lipa Na M-Pesa)',
                subtitle: 'Instant STK prompt on your phone',
                icon: Icons.phone_android_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBgColor: const Color(0xFFDCFCE7),
                trailingBadge: 'RECOMMENDED',
                isEnabled: true,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(
                      'M-Pesa Phone Number',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _mpesaPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
                        hintText: '07XX XXXXXX',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Cash on Delivery Option (Disabled with Coming Soon badge)
              _buildPaymentCard(
                id: 'cod',
                title: 'Cash on Delivery',
                subtitle: 'Pay cash or M-Pesa directly to the courier rider upon delivery',
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFF94A3B8),
                iconBgColor: const Color(0xFFF1F5F9),
                trailingBadge: 'COMING SOON',
                isComingSoon: true,
                isEnabled: false,
              ),
              const SizedBox(height: 14),

              // 3. Debit / Credit Card Option (Disabled with Coming Soon badge)
              _buildPaymentCard(
                id: 'card',
                title: 'Credit / Debit Card',
                subtitle: 'Visa, Mastercard & American Express',
                icon: Icons.credit_card_rounded,
                iconColor: const Color(0xFF94A3B8),
                iconBgColor: const Color(0xFFF1F5F9),
                trailingBadge: 'COMING SOON',
                isComingSoon: true,
                isEnabled: false,
              ),
              const SizedBox(height: 36),

              AppButton(
                text: 'Save Payment Preference',
                isLoading: _isSaving,
                onPressed: _savePaymentPreference,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    String? trailingBadge,
    bool isEnabled = true,
    bool isComingSoon = false,
    Widget? content,
  }) {
    final isSelected = _selectedMethod == id;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.65,
      child: InkWell(
        onTap: isEnabled
            ? () {
                // Keep selected
              }
            : null,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppTextStyles.bodySemiBold.copyWith(
                                  fontSize: 14,
                                  color: isEnabled ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (trailingBadge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isComingSoon
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: isComingSoon
                                      ? Border.all(color: const Color(0xFFCBD5E1))
                                      : null,
                                ),
                                child: Text(
                                  trailingBadge,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isComingSoon
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : (isEnabled ? Icons.radio_button_off : Icons.lock_outline_rounded),
                    color: isSelected
                        ? AppColors.primary
                        : (isEnabled ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8)),
                    size: isEnabled ? 22 : 18,
                  ),
                ],
              ),
              if (isSelected && content != null) content,
            ],
          ),
        ),
      ),
    );
  }
}
