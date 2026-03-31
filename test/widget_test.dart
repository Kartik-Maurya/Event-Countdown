import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:event_countdown/main.dart';

void main() {
  testWidgets('App renders with Event Countdown title', (WidgetTester tester) async {
    await tester.pumpWidget(const EventCountdownApp(isDarkMode: false));
    await tester.pumpAndSettle();
    expect(find.text('Event Countdown'), findsOneWidget);
  });

  testWidgets('FAB is present for adding events', (WidgetTester tester) async {
    await tester.pumpWidget(const EventCountdownApp(isDarkMode: false));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Dark mode toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(const EventCountdownApp(isDarkMode: false));
    await tester.pumpAndSettle();
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);
  });
}
