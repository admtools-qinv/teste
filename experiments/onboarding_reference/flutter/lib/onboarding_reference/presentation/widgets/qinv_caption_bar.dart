import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../theme/qinvweb3_tokens.dart';

class QInvCaptionBar extends StatelessWidget {
  final String text;
  final VoidCallback? onReplay;

  const QInvCaptionBar({super.key, required this.text, this.onReplay});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Semantics(
      container: true,
      label: context.l10n.semanticsNarrationCaption,
      value: text,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: QInvWeb3Tokens.cardBgDropdown,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360 || textScale > 1.15;
            final caption = Text(
              text,
              textAlign: TextAlign.left,
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: QInvWeb3Tokens.fontSizeSmall,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: QInvWeb3Tokens.textSecondary,
                height: 1.55,
                letterSpacing: 0.1,
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  caption,
                  if (onReplay != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        color: QInvWeb3Tokens.primaryLight,
                        onPressed: onReplay,
                        tooltip: context.l10n.tooltipReplayNarration,
                      ),
                    ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: caption),
                if (onReplay != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    color: QInvWeb3Tokens.primaryLight,
                    onPressed: onReplay,
                    tooltip: context.l10n.tooltipReplayNarration,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
