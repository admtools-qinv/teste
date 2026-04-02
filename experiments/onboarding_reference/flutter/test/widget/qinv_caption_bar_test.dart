import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

void main() {
  testWidgets('renders caption text with overflow safety', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QInvCaptionBar(text: 'Caption text'),
        ),
      ),
    );

    expect(find.text('Caption text'), findsOneWidget);
  });
}
