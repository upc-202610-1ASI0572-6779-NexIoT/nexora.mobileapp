// Basic smoke test: verifies the app builds and renders a frame.

import 'package:flutter_test/flutter_test.dart';

import 'package:nexoraiot/app/app.dart';

void main() {
  testWidgets('NexoraApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NexoraApp());
    await tester.pumpAndSettle();
  });
}
