import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/qinvweb3_tokens.dart';

class QInvButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outline;
  final bool busy;
  final bool selected;

  const QInvButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outline = false,
    this.busy = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    VoidCallback? hapticOnPressed;
    if (onPressed != null) {
      hapticOnPressed = () {
        HapticFeedback.mediumImpact();
        onPressed!();
      };
    }

    final spinner = SizedBox(
      height: 17,
      width: 17,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          outline ? QInvWeb3Tokens.primary : QInvWeb3Tokens.primaryForeground,
        ),
      ),
    );

    final labelWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (selected) ...[
          const Icon(Icons.check_circle_rounded, size: 16),
          const SizedBox(width: 7),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final busyWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        spinner,
        const SizedBox(width: 10),
        Text(label, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
      ],
    );

    final child = AnimatedSwitcher(
      duration: QInvWeb3Tokens.transitionAll,
      child: busy ? busyWidget : labelWidget,
    );

    final button = outline
        ? OutlinedButton(
            onPressed: enabled ? hapticOnPressed : null,
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  selected ? QInvWeb3Tokens.primary.withValues(alpha: 0.14) : null,
              foregroundColor:
                  selected ? QInvWeb3Tokens.primaryLight : QInvWeb3Tokens.textSecondary,
              side: BorderSide(
                color: selected
                    ? QInvWeb3Tokens.primaryLight.withValues(alpha: 0.65)
                    : Colors.white.withValues(alpha: 0.15),
                width: selected ? 1.5 : 1.0,
              ),
              minimumSize: const Size.fromHeight(54),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              textStyle: const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: QInvWeb3Tokens.fontSizeLabel,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusButton),
              ),
            ),
            child: child,
          )
        : AnimatedContainer(
            duration: QInvWeb3Tokens.transitionAll,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusButton),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: QInvWeb3Tokens.primary.withValues(alpha: 0.40),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              onPressed: enabled ? hapticOnPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: QInvWeb3Tokens.primary,
                foregroundColor: QInvWeb3Tokens.primaryForeground,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.28),
                minimumSize: const Size.fromHeight(54),
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusButton),
                ),
                textStyle: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeLabel,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              child: child,
            ),
          );

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: label,
      value: busy ? 'Loading' : (selected ? 'Selected' : null),
      child: button,
    );
  }
}
