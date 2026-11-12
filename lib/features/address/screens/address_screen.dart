// lib/features/address/screens/address_screen.dart

import 'package:flutter/material.dart';
import 'my_addresses_screen.dart';

export 'my_addresses_screen.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyAddressesScreen();
  }
}
