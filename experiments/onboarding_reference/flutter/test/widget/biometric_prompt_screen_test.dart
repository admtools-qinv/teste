import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

Widget _buildScreen({
  VoidCallback? onEnabled,
  VoidCallback? onSkipped,
}) {
  return MaterialApp(
    theme: QInvWeb3Theme.dark(),
    home: BiometricPromptScreen(
      onEnabled: onEnabled ?? () {},
      onSkipped: onSkipped ?? () {},
    ),
  );
}

void main() {
  // ── Content ───────────────────────────────────────────────────

  group('content', () {
    testWidgets('shows the title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.text('Login com biometria?'), findsOneWidget);
    });

    testWidgets('shows fingerprint icon', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    });

    testWidgets('shows both action buttons', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(
        find.widgetWithText(ElevatedButton, 'Sim, usar biometria'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, 'Não, obrigado'),
        findsOneWidget,
      );
    });

    testWidgets('shows explanatory body text', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(
        find.textContaining('digital ou reconhecimento facial'),
        findsOneWidget,
      );
    });
  });

  // ── Callbacks ─────────────────────────────────────────────────

  group('callbacks', () {
    testWidgets('"Sim, usar biometria" calls onEnabled exactly once',
        (tester) async {
      int count = 0;
      await tester.pumpWidget(_buildScreen(onEnabled: () => count++));
      await tester.pump();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Sim, usar biometria'),
      );
      await tester.pump();
      expect(count, equals(1));
    });

    testWidgets('"Não, obrigado" calls onSkipped exactly once', (tester) async {
      int count = 0;
      await tester.pumpWidget(_buildScreen(onSkipped: () => count++));
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Não, obrigado'));
      await tester.pump();
      expect(count, equals(1));
    });

    testWidgets('tapping "Não" does NOT call onEnabled', (tester) async {
      bool enabledCalled = false;
      await tester.pumpWidget(
        _buildScreen(onEnabled: () => enabledCalled = true),
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Não, obrigado'));
      await tester.pump();
      expect(enabledCalled, isFalse);
    });

    testWidgets('tapping "Sim" does NOT call onSkipped', (tester) async {
      bool skippedCalled = false;
      await tester.pumpWidget(
        _buildScreen(onSkipped: () => skippedCalled = true),
      );
      await tester.pump();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Sim, usar biometria'),
      );
      await tester.pump();
      expect(skippedCalled, isFalse);
    });
  });
}
