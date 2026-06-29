import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexoraiot/contexts/properties/infrastructure/repositories/fake_properties_repository.dart';
import 'package:nexoraiot/contexts/properties/domain/entities/app_data.dart';
import 'package:nexoraiot/contexts/properties/presentation/pages/home_page.dart';

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

  testWidgets('HomePage displays general system status and metrics correctly',
      (tester) async {
    await pump(tester, HomePage(data: data));

    // Platform status based on mock data (has critical alerts)
    expect(find.text('ALERTA CRÍTICA'), findsOneWidget);
    expect(find.text('2 incidentes críticos que requieren atención'), findsOneWidget);

    // Device counts: total = 8
    expect(find.text('8'), findsWidgets);
    expect(find.text('Registrados'), findsOneWidget);
    expect(find.text('Conectados'), findsOneWidget);
    expect(find.text('Desconectados'), findsOneWidget);
    expect(find.text('Anomalías'), findsOneWidget);
    
    // We expect "6" to be displayed twice (Connected Devices: 6, Total Alerts: 6)
    expect(find.text('6'), findsNWidgets(2));

    // We expect "2" to be displayed four times:
    // 1. Disconnected Devices (2)
    // 2. Critical Alerts (2)
    // 3. Solved Alerts (2)
    // 4. Living Room Devices count (2)
    expect(find.text('2'), findsNWidgets(4));

    // Alerts summary
    expect(find.text('Generadas'), findsOneWidget);
    expect(find.text('Activas'), findsOneWidget);
    expect(find.text('Críticas'), findsOneWidget);
    expect(find.text('Resueltas'), findsOneWidget);

    // Sensors summary: total = 11
    expect(find.text('11'), findsOneWidget);
    expect(find.text('Monitoreados'), findsOneWidget);
    expect(find.text('Gas Natural'), findsOneWidget);
    expect(find.text('Flujo de Agua'), findsOneWidget);
    expect(find.text('Consumo Eléc.'), findsOneWidget);

    // Room distribution (shows sectors)
    expect(find.text('Kitchen'), findsWidgets);
    expect(find.text('Living Room'), findsWidgets);
    expect(find.text('Basement'), findsWidgets);

    // Recent activity tiles (first 3 incidents)
    expect(find.text('Water Leak Detected'), findsOneWidget);
    expect(find.text('Power Surge'), findsOneWidget);
    expect(find.text('Motion in Backyard'), findsOneWidget);
  });
}
