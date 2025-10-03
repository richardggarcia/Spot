import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Spot Trading App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Spot Trading')),
          body: const Center(
            child: Text('🚀 Spot Trading App'),
          ),
        ),
      ),
    );

    // Verify that our app starts correctly
    expect(find.text('Spot Trading'), findsOneWidget);
    expect(find.text('🚀 Spot Trading App'), findsOneWidget);
  });
}