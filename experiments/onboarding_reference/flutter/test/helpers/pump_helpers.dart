import 'package:flutter_test/flutter_test.dart';

const kSettleDuration = Duration(milliseconds: 50);
const kAnimationDuration = Duration(milliseconds: 500);

/// Pumps enough frames for immediately-resolving async to complete
/// without pumpAndSettle (which hangs on infinite animations).
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(kSettleDuration);
  await tester.pump();
}

/// Pumps enough frames for finite flutter_animate animations
/// without blocking on infinite background loops (e.g. GlassBackground orb).
Future<void> pumpAnimations(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(kAnimationDuration);
}
