// lib/features/address/screens/sections/address_list_section.dart

import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/address_model.dart';

class AddressListSection extends StatelessWidget {
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final ValueChanged<AddressModel> onSelectAddress;
  final ValueChanged<AddressModel> onEditAddress;
  final ValueChanged<AddressModel> onDeleteAddress;
  final double Function(AddressModel) getDistanceKm;

  const AddressListSection({
    super.key,
    required this.addresses,
    required this.selectedAddress,
    required this.onSelectAddress,
    required this.onEditAddress,
    required this.onDeleteAddress,
    required this.getDistanceKm,
  });

  void _confirmDelete(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address?'),
        content: Text('Are you sure you want to remove "${address.label} - ${address.area}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleteAddress(address);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Addresses (${addresses.length})',
              style: AppTextStyles.h2.copyWith(fontSize: 16),
            ),
            Text(
              'Max 10',
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (addresses.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                'No saved addresses yet. Tap "+ Add New Address" below.',
                style: AppTextStyles.caption,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final addr = addresses[index];
              final isSelected = selectedAddress?.id == addr.id;
              final dist = getDistanceKm(addr);
              final isOutOfRange = dist > AppConfig.maxDeliveryRadiusKm;

              return InkWell(
                onTap: () => onSelectAddress(addr),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isOutOfRange
                              ? AppColors.error.withValues(alpha: 0.3)
                              : Colors.grey.shade200,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Radio check indicator
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected ? AppColors.primary : Colors.grey.shade400,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Address info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    addr.label,
                                    style: AppTextStyles.bodySemiBold.copyWith(
                                      fontSize: 14,
                                      color: AppColors.slateDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (addr.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'DEFAULT',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addr.displayAddress,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${addr.recipientName} • ${addr.recipientPhone}',
                              style: AppTextStyles.caption.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 6),

                            // Distance Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isOutOfRange
                                    ? AppColors.error.withValues(alpha: 0.1)
                                    : AppColors.inputBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isOutOfRange
                                        ? Icons.error_outline_rounded
                                        : Icons.near_me_outlined,
                                    size: 12,
                                    color: isOutOfRange ? AppColors.error : AppColors.primaryDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isOutOfRange
                                        ? '${dist.toStringAsFixed(1)} km (Outside 7km radius)'
                                        : '${dist.toStringAsFixed(1)} km from Bansi Mega',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isOutOfRange ? AppColors.error : AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Actions (Edit, Delete)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: AppColors.slateDark,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onEditAddress(addr),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            color: AppColors.error,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _confirmDelete(context, addr),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
