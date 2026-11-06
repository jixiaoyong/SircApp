import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirc/main.dart';

void main() {
  testWidgets('App smoke test - initializes without error',
      (WidgetTester tester) async {
    // Set a realistic screen size for test binding
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.reset());

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify root widget structure builds properly
    expect(find.byType(MyApp), findsOneWidget);
  });
}
