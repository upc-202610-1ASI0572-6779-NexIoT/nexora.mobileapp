import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('DevicesPage displays summaries and filters by status correctly',
      (tester) async {
    await pump(tester, DevicesPage(data: data));

    // Summary indicators
    expect(find.text('8'), findsWidgets); // Total: 8 devices
    expect(find.text('6'), findsOneWidget); // Connected: 6
    expect(find.text('2'), findsWidgets); // Inactive: 2
    expect(find.text('1'), findsWidgets); // Anomalies: 1

    // Initially we see online and offline devices
    expect(find.text('ONLINE'), findsNWidgets(6));
    expect(find.text('OFFLINE'), findsNWidgets(2));

    // Filter by Inactive status
    final inactiveFinder = find.text('Inactive (2)');
    await tester.ensureVisible(inactiveFinder);
    await tester.tap(inactiveFinder);
    await tester.pumpAndSettle();

    expect(find.text('ONLINE'), findsNothing);
    expect(find.text('OFFLINE'), findsNWidgets(2));
    expect(find.text('Basement'), findsOneWidget); // Basement is inactive
    expect(find.text('Garage'), findsOneWidget); // Garage is inactive

    // Filter by Anomalies status
    final anomaliesFinder = find.text('Anomalies (1)');
    await tester.ensureVisible(anomaliesFinder);
    await tester.tap(anomaliesFinder);
    await tester.pumpAndSettle();

    expect(find.text('ONLINE'), findsNWidgets(1)); // Kitchen Floor 2 has alert but is connected/online
    expect(find.text('OFFLINE'), findsNothing);
    expect(find.text('ALERTA'), findsOneWidget); // Anomalies show the alert badge

    // Clear filters (Any Status)
    final anyStatusFinder = find.text('Any Status');
    await tester.ensureVisible(anyStatusFinder);
    await tester.tap(anyStatusFinder);
    await tester.pumpAndSettle();

    expect(find.text('ONLINE'), findsNWidgets(6));
    expect(find.text('OFFLINE'), findsNWidgets(2));
  });
}
