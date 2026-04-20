import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/qinvweb3_tokens.dart';

class OnboardingOptionCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final String? assetPath;

  const OnboardingOptionCard({
    super.key,
    required this.label,
    this.subtitle,
    required this.selected,
    required this.enabled,
    this.onTap,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: QInvWeb3Tokens.transitionFast,
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minHeight: 58),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusOption),
        color: selected
            ? QInvWeb3Tokens.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: selected
              ? QInvWeb3Tokens.primaryLight.withValues(alpha: 0.70)
              : Colors.white.withValues(alpha: 0.09),
          width: selected ? 1.5 : 1.0,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: QInvWeb3Tokens.primary.withValues(alpha: 0.28),
                  blurRadius: QInvWeb3Tokens.blurGlass,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusOption),
          splashColor: QInvWeb3Tokens.primary.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                if (assetPath != null) ...[
                  SvgPicture.asset(assetPath!, height: 40),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: QInvWeb3Tokens.fontUI,
                          fontSize: 15.0,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : QInvWeb3Tokens.textSecondary,
                          height: 1.35,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontFamily: QInvWeb3Tokens.fontUI,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.45),
                            height: 1.3,
                            letterSpacing: 0.05,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedSwitcher(
                  duration: QInvWeb3Tokens.transitionFast,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                      CurvedAnimation(
                          parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('check'),
                          color: QInvWeb3Tokens.primaryLight,
                          size: 16,
                        )
                      : Container(
                          key: const ValueKey('empty'),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                              width: 1.5,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
