import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexoraiot/contexts/alerts/presentation/pages/alerts_page.dart';
import 'package:nexoraiot/contexts/consumption/presentation/pages/consumption_page.dart';
import 'package:nexoraiot/contexts/properties/infrastructure/repositories/fake_properties_repository.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/devices/presentation/pages/devices_page.dart';

void main() {
  const size = Size(390, 844);

  late AppData data;

  setUp(() async {
    data = await FakePropertiesRepository().getDashboardData();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    await tester.pumpAndSettle();
  }

  testWidgets('devices room filter narrows the device list', (tester) async {
    await pump(tester, DevicesPage(data: data));

    // Initially every section is visible.
    expect(find.text('Basement'), findsOneWidget); // gas, room=Basement
    expect(find.text('HUMIDITY'), findsOneWidget);

    // Filter to Kitchen.
    await tester.tap(find.text('Kitchen (3)'));
    await tester.pumpAndSettle();

    expect(find.text('Basement'), findsNothing); // not a Kitchen device
    expect(find.text('HUMIDITY'), findsNothing); // no Kitchen humidity sensors
    expect(find.text('GAS SENSOR'), findsOneWidget); // has Kitchen sensors

    // Back to all.
    await tester.tap(find.text('All (8)'));
    await tester.pumpAndSettle();
    expect(find.text('Basement'), findsOneWidget);
  });

  testWidgets('alerts status filter switches the incident list',
      (tester) async {
    await pump(tester, AlertsPage(data: data));

    // All: both active and solved incidents present.
    expect(find.text('Water Leak Detected'), findsOneWidget);
    expect(find.text('Smoke Sensor Triggered'), findsOneWidget);

    // Active hides solved incidents (4 active, 2 solved seeded).
    await tester.ensureVisible(find.text('Active • 4'));
    await tester.tap(find.text('Active • 4'));
    await tester.pumpAndSettle();
    expect(find.text('Water Leak Detected'), findsOneWidget);
    expect(find.text('Smoke Sensor Triggered'), findsNothing);

    // Solved hides active incidents.
    await tester.ensureVisible(find.text('Solved • 2'));
    await tester.tap(find.text('Solved • 2'));
    await tester.pumpAndSettle();
    expect(find.text('Water Leak Detected'), findsNothing);
    expect(find.text('Smoke Sensor Triggered'), findsOneWidget);
  });

  testWidgets('reports metric + range filters switch the dataset',
      (tester) async {
    await pump(tester, ConsumptionPage(data: data));

    // Water / Week is the default.
    expect(find.text('1,847'), findsOneWidget);

    // Switch to Day.
    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(find.text('284'), findsOneWidget);
    expect(find.text('1,847'), findsNothing);

    // Switch metric to Electricity (still Day).
    await tester.tap(find.text('Electricity'));
    await tester.pumpAndSettle();
    expect(find.text('6.2'), findsOneWidget);
    expect(find.text('284'), findsNothing);
  });
}
