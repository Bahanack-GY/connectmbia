import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbiaconsulting/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MbiaConsultingApp());
    await tester.pumpAndSettle();

    // Verify that the title appears or just that it doesn't crash
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
