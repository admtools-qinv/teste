import 'package:flutter/material.dart';

import '../../theme/qinvweb3_tokens.dart';

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
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: QInvWeb3Tokens.cardBgLight,
        borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
        border: Border.all(color: QInvWeb3Tokens.border),
      ),
      child: child,
    );
  }
}
