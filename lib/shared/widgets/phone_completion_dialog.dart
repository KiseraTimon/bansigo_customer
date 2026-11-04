// lib/shared/widgets/phone_completion_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'app_button.dart';
import 'app_text_field.dart';

class PhoneCompletionDialog extends StatefulWidget {
  const PhoneCompletionDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PhoneCompletionDialog(),
    );
  }

  @override
  State<PhoneCompletionDialog> createState() => _PhoneCompletionDialogState();
}

class _PhoneCompletionDialogState extends State<PhoneCompletionDialog> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitPhone() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final rawPhone = _phoneController.text.trim();
    final normalised = Validators.normalisePhone(rawPhone) ?? rawPhone;

    final success = await auth.completePhone(normalised);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = auth.errorMessage ?? 'Failed to update phone number';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Complete Your Profile', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            Text(
              'Enter your Kenyan mobile number for order delivery confirmations and M-Pesa payments:',
              style: AppTextStyles.subtitle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _phoneController,
              label: 'Kenyan Mobile Number',
              hint: '0712345678 or 0112345678',
              keyboardType: TextInputType.phone,
              autofocus: true,
              prefix: Container(
                width: 72,
                alignment: Alignment.center,
                child: Text(
                  '🇰🇪 +254',
                  style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
                ),
              ),
              validator: Validators.validatePhone,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 20),
            AppButton(
              text: 'Save Phone Number',
              isLoading: _isSubmitting,
              onPressed: _submitPhone,
            ),
          ],
        ),
      ),
    );
  }
}
