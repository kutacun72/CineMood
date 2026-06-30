import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinemood/views/login_view/login_view.dart';

void main() {
  testWidgets('Login screen renders CineMood entry points', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));

    expect(find.text('CineMood'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);

    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}
