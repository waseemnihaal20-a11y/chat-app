import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chat_app/main.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MiniChatApp());
    await tester.pumpAndSettle();

    // Verify that the app renders the main screen
    expect(find.text('Mini Chat'), findsOneWidget);
  });

  testWidgets('Bottom navigation should have 3 tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MiniChatApp());
    await tester.pumpAndSettle();

    // Find navigation bar
    expect(find.byType(NavigationBar), findsOneWidget);

    // Find navigation destinations
    expect(find.byType(NavigationDestination), findsNWidgets(3));
  });

  testWidgets('Home tab should show custom switcher', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MiniChatApp());
    await tester.pumpAndSettle();

    // Should show the tab switcher options
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Chat History'), findsOneWidget);
  });
}
