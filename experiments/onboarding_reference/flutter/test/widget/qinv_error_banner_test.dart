import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

import '../helpers/test_app.dart';

void main() {
  Widget buildBanner(String message) {
    return buildTestApp(
      home: Scaffold(
        body: QInvErrorBanner(message: message),
      ),
    );
  }

  group('QInvErrorBanner', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(buildBanner('Something went wrong'));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows error icon', (tester) async {
      await tester.pumpWidget(buildBanner('Error'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('semantics has liveRegion flag', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildBanner('Network error'));
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(QInvErrorBanner));
      expect(semantics.hasFlag(SemanticsFlag.isLiveRegion), isTrue);
      handle.dispose();
    });

    testWidgets('long message wraps without overflow', (tester) async {
      final longMessage = 'Error: ' * 50;
      await tester.pumpWidget(buildBanner(longMessage));
      await tester.pumpAndSettle();

      // No overflow exception means test passes.
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });
}
