// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bansigo_customer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const BansiGoApp(
        initialRoute: Scaffold(
          body: Center(
            child: Text('BansiGo Test'),
          ),
        ),
      ),
    );

    expect(find.text('BansiGo Test'), findsOneWidget);
  });
}
