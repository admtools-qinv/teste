import 'package:flutter/material.dart';

import '../../theme/qinvweb3_tokens.dart';
import 'glass_widgets.dart';

class QInvStepCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const QInvStepCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      fillColor: QInvWeb3Tokens.cardBgDropdown.withValues(alpha: 0.38),
      borderColor: Colors.white.withValues(alpha: 0.10),
      blurSigma: 28,
      child: child,
    );
  }
}
