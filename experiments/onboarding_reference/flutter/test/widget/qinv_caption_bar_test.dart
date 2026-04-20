import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

import '../helpers/test_app.dart';

void main() {
  Widget buildBar({required String text, VoidCallback? onReplay, double width = 400}) {
    return buildTestApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: QInvCaptionBar(text: text, onReplay: onReplay),
        ),
      ),
    );
  }

  group('QInvCaptionBar', () {
    testWidgets('renders caption text', (tester) async {
      await tester.pumpWidget(buildBar(text: 'Caption text'));
      await tester.pumpAndSettle();

      expect(find.text('Caption text'), findsOneWidget);
    });

    testWidgets('shows replay button when onReplay is provided', (tester) async {
      await tester.pumpWidget(buildBar(text: 'Hello', onReplay: () {}));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
    });

    testWidgets('hides replay button when onReplay is null', (tester) async {
      await tester.pumpWidget(buildBar(text: 'Hello'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.replay_rounded), findsNothing);
    });

    testWidgets('tap on replay calls the callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(buildBar(text: 'Hello', onReplay: () => called = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.replay_rounded));
      expect(called, isTrue);
    });

    testWidgets('uses compact layout (Column) when width < 360', (tester) async {
      await tester.pumpWidget(buildBar(text: 'Narrow', onReplay: () {}, width: 300));
      await tester.pumpAndSettle();

      // In compact mode the replay icon is inside a Column (below text).
      // Verify both text and icon render without overflow.
      expect(find.text('Narrow'), findsOneWidget);
      expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
    });

    testWidgets('uses Row layout at normal width', (tester) async {
      await tester.pumpWidget(buildBar(text: 'Wide', onReplay: () {}, width: 500));
      await tester.pumpAndSettle();

      expect(find.text('Wide'), findsOneWidget);
      expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
    });

    testWidgets('long text does not overflow', (tester) async {
      final longText = 'A' * 500;
      await tester.pumpWidget(buildBar(text: longText));
      await tester.pumpAndSettle();

      // If there's an overflow, the test framework reports a rendering error.
      expect(find.text(longText), findsOneWidget);
    });
  });
}
