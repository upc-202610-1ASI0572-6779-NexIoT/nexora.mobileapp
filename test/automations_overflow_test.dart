import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexoraiot/contexts/automations/domain/entities/automation.dart';
import 'package:nexoraiot/contexts/automations/presentation/pages/automations_page.dart';
import 'package:nexoraiot/contexts/automations/presentation/pages/new_automation_flow.dart';

List<Automation> _seed() => [
      Automation(
        name: 'Vacation Mode · Eco',
        trigger: TriggerType.location,
        action: ActionType.controlDevice,
        onlyWhenNobodyHome: true,
      ),
      Automation(
        name: 'Leak Auto Shutoff',
        trigger: TriggerType.sensorValue,
        action: ActionType.securityUpdate,
        timerMinutes: 5,
      ),
    ];

void _expectNoOverflow(WidgetTester tester) {
  final exception = tester.takeException();
  expect(exception, isNull, reason: 'overflow/exception detected: $exception');
}

void main() {
  // iPhone-ish logical size.
  const size = Size(390, 844);

  testWidgets('AutomationsPage has no overflow', (tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: AutomationsPage(automations: _seed())),
    );
    await tester.pumpAndSettle();
    _expectNoOverflow(tester);
  });

  testWidgets('active count refreshes when an automation is toggled',
      (tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: AutomationsPage(automations: _seed())),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 Active'), findsOneWidget);

    // Turn the first automation off.
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('1 Active'), findsOneWidget);
  });

  testWidgets('New automation wizard steps have no overflow', (tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: NewAutomationFlow()));
    await tester.pumpAndSettle();
    _expectNoOverflow(tester);

    // Step 1 -> 2
    await tester.tap(find.text('Device state'));
    await tester.pumpAndSettle();
    _expectNoOverflow(tester);

    // Step 2 -> 3
    await tester.tap(find.text('Control device'));
    await tester.pumpAndSettle();
    _expectNoOverflow(tester);

    // Step 3 -> 4
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    _expectNoOverflow(tester);
  });
}
