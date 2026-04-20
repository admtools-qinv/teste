import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding_reference/onboarding_reference.dart';

import '../helpers/test_app.dart';

void main() {
  Widget buildButton({
    String label = 'Continue',
    VoidCallback? onPressed,
    bool outline = false,
    bool busy = false,
    bool selected = false,
  }) {
    return buildTestApp(
      home: Scaffold(
        body: QInvButton(
          label: label,
          onPressed: onPressed,
          outline: outline,
          busy: busy,
          selected: selected,
        ),
      ),
    );
  }

  group('QInvButton - filled variant', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(buildButton(label: 'Submit'));
      await tester.pump();
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('uses ElevatedButton', (tester) async {
      await tester.pumpWidget(buildButton());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      int count = 0;
      await tester.pumpWidget(buildButton(onPressed: () => count++));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(count, 1);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(buildButton(onPressed: null));
      await tester.pump();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('disabled when busy is true even with onPressed set', (tester) async {
      await tester.pumpWidget(buildButton(onPressed: () {}, busy: true));
      await tester.pump();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('QInvButton - outline variant', () {
    testWidgets('uses OutlinedButton when outline is true', (tester) async {
      await tester.pumpWidget(buildButton(outline: true, onPressed: () {}));
      await tester.pump();
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('QInvButton - busy state', () {
    testWidgets('shows spinner when busy', (tester) async {
      await tester.pumpWidget(buildButton(onPressed: () {}, busy: true));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('still shows label text when busy', (tester) async {
      await tester.pumpWidget(buildButton(label: 'Loading', onPressed: () {}, busy: true));
      await tester.pump();
      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('no spinner when not busy', (tester) async {
      await tester.pumpWidget(buildButton(onPressed: () {}));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('QInvButton - selected state', () {
    testWidgets('shows check icon when selected', (tester) async {
      await tester.pumpWidget(buildButton(onPressed: () {}, selected: true));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('no check icon when not selected', (tester) async {
      await tester.pumpWidget(buildButton(onPressed: () {}));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });
  });

  group('QInvButton - semantics', () {
    testWidgets('has button semantics with label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildButton(label: 'Next', onPressed: () {}));
      await tester.pump();

      final semantics = tester.getSemantics(find.byType(QInvButton));
      expect(semantics.label, contains('Next'));
      handle.dispose();
    });

    testWidgets('semantics value indicates loading when busy', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildButton(onPressed: () {}, busy: true));
      await tester.pump();

      final semantics = tester.getSemantics(find.byType(QInvButton));
      expect(semantics.value, equals('Loading'));
      handle.dispose();
    });

    testWidgets('semantics value indicates selected when selected', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildButton(onPressed: () {}, selected: true));
      await tester.pump();

      final semantics = tester.getSemantics(find.byType(QInvButton));
      expect(semantics.value, equals('Selected'));
      handle.dispose();
    });
  });
}
