import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexoraiot/contexts/automations/presentation/pages/new_automation_flow.dart';

void main() {
  testWidgets('setting a custom timer does not crash', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewAutomationFlow()));
    await tester.pumpAndSettle();

    // Step 1 -> 2 -> 3 (timer step).
    await tester.tap(find.text('Device state'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Control device'));
    await tester.pumpAndSettle();

    // Open the custom timer dialog.
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    // Enter a value and confirm.
    await tester.enterText(find.byType(TextField), '45');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('45'), findsOneWidget); // big timer box shows 45
  });
}
