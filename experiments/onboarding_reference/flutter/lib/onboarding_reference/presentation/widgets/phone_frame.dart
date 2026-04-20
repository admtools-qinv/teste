import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PhoneFrame extends StatelessWidget {
  final String assetPath;
  static const _package = 'onboarding_reference';
  static const _bezelRadius = 44.0;
  static const _bezelBorder = 8.0;
  static const _screenRadius = _bezelRadius - _bezelBorder;

  const PhoneFrame({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.80,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(_bezelRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 28,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(_bezelBorder),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_screenRadius),
                child: Image.asset(
                  assetPath,
                  package: _package,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xFF121314),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.08, end: 0, duration: 620.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 500.ms);
  }
}
