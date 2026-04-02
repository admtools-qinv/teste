import 'package:flutter/material.dart';

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

    final spinner = SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
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
          const Icon(Icons.check_circle_rounded, size: 18),
          const SizedBox(width: 8),
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
        Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final child = AnimatedSwitcher(
      duration: QInvWeb3Tokens.transitionAll,
      child: busy ? busyWidget : labelWidget,
    );

    final button = outline
        ? OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              backgroundColor: selected ? QInvWeb3Tokens.primary.withValues(alpha: 0.16) : null,
              foregroundColor: selected ? QInvWeb3Tokens.primary : null,
              side: BorderSide(
                color: selected ? QInvWeb3Tokens.primary : QInvWeb3Tokens.border,
                width: selected ? 1.4 : 1.0,
              ),
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              textStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
              ),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: QInvWeb3Tokens.primary,
              foregroundColor: QInvWeb3Tokens.primaryForeground,
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            child: child,
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
