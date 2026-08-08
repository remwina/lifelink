// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:lifelink/main.dart';

void main() {
  testWidgets('LifeLink renders its startup setup banner', (tester) async {
    await tester.pumpWidget(
      const LifeLinkApp(firebaseReady: false, demoMode: false),
    );

    expect(find.text('Firebase not configured'), findsOneWidget);
  });
}
