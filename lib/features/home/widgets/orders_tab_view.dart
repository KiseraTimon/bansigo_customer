// lib/features/home/widgets/orders_tab_view.dart

import 'package:flutter/material.dart';
import '../../orders/screens/orders_screen.dart';

class OrdersTabView extends StatelessWidget {
  final VoidCallback onStartShopping;

  const OrdersTabView({
    super.key,
    required this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    return OrdersScreen(onStartShopping: onStartShopping);
  }
}
