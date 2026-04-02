import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

void main() {
  testWidgets('renders error message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QInvErrorBanner(message: 'Something went wrong'),
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
  });
}
