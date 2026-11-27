// lib/features/address/screens/my_addresses_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/templates/screen_template.dart';
import '../models/address_model.dart';
import '../providers/address_provider.dart';
import 'map_location_picker_screen.dart';
import 'sections/my_address_card.dart';

import '../../../shared/widgets/app_toast.dart';
class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AddressProvider>().loadData();
      }
    });
  }

  void _navigateToAddAddress(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MapLocationPickerScreen(),
      ),
    );
    if (result == true && context.mounted) {
      context.read<AddressProvider>().loadData();
    }
  }

  void _navigateToEditAddress(BuildContext context, AddressModel address) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(addressToEdit: address),
      ),
    );
    if (result == true && context.mounted) {
      context.read<AddressProvider>().loadData();
    }
  }

  void _confirmDeleteAddress(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final ok = await context.read<AddressProvider>().deleteAddress(address.id);
              if (ok && context.mounted) {
                AppToast.show(context, 'Deleted "${address.label}"', type: AppToastType.error, duration: const Duration(seconds: 2));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      isScrollable: false,
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
                'My Addresses',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateDark,
                ),
              ),
              const Spacer(),
              Consumer<AddressProvider>(
                builder: (_, prov, __) => prov.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primaryDark),
                        onPressed: () => prov.loadData(),
                        tooltip: 'Refresh addresses',
                      ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          final addresses = provider.addresses;
          final selected = provider.selectedAddress;

          if (provider.isLoading && addresses.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (addresses.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.loadData(),
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved addresses yet',
                          style: AppTextStyles.bodySemiBold.copyWith(
                            fontSize: 16,
                            color: AppColors.slateDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap the button below to add your delivery location.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            color: AppColors.primary,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFFF1F5F9),
                thickness: 1,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final addr = addresses[index];
                final isCurrent = selected?.id == addr.id;

                return MyAddressCard(
                  address: addr,
                  isSelected: isCurrent,
                  onSelect: () {
                    provider.selectAddress(addr);
                    AppToast.dismiss();
                    AppToast.show(context, 'Active delivery set to "${addr.label}"', type: AppToastType.success, duration: const Duration(seconds: 1));
                  },
                  onEdit: () => _navigateToEditAddress(context, addr),
                  onDelete: () => _confirmDeleteAddress(context, addr),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _navigateToAddAddress(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add New Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.add,
                    size: 22,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
