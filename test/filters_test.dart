import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexoraiot/contexts/alerts/presentation/pages/alerts_page.dart';
import 'package:nexoraiot/contexts/consumption/presentation/pages/consumption_page.dart';
import 'package:nexoraiot/contexts/devices/presentation/pages/devices_page.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/properties/infrastructure/repositories/fake_properties_repository.dart';

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

    expect(find.text('Basement'), findsOneWidget);
    expect(find.text('HUMIDITY'), findsOneWidget);

    await tester.tap(find.text('Kitchen (3)'));
    await tester.pumpAndSettle();

    expect(find.text('Basement'), findsNothing);
    expect(find.text('HUMIDITY'), findsNothing);
    expect(find.text('GAS SENSOR'), findsOneWidget);

    await tester.tap(find.text('All (8)'));
    await tester.pumpAndSettle();
    expect(find.text('Basement'), findsOneWidget);
  });

  testWidgets('alerts status filter switches the incident list', (
    tester,
  ) async {
    await pump(tester, AlertsPage(data: data));

    expect(find.text('Water leak detected'), findsOneWidget);
    expect(find.text('Kitchen circuit high consumption'), findsOneWidget);

    await tester.ensureVisible(find.text('Activas').last);
    await tester.tap(find.text('Activas').last);
    await tester.pumpAndSettle();
    expect(find.text('Water leak detected'), findsOneWidget);
    expect(find.text('Kitchen circuit high consumption'), findsNothing);

    await tester.ensureVisible(find.text('Res.').last);
    await tester.tap(find.text('Res.').last);
    await tester.pumpAndSettle();
    expect(find.text('Water leak detected'), findsNothing);
    expect(find.text('Kitchen circuit high consumption'), findsOneWidget);
  });

  testWidgets('reports metric + range filters switch the dataset', (
    tester,
  ) async {
    await pump(tester, ConsumptionPage(data: data));

    expect(find.text('1,847'), findsOneWidget);

    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();
    expect(find.text('284'), findsOneWidget);
    expect(find.text('1,847'), findsNothing);

    await tester.tap(find.text('Electricity'));
    await tester.pumpAndSettle();
    expect(find.text('6.2'), findsOneWidget);
    expect(find.text('284'), findsNothing);
  });
}
