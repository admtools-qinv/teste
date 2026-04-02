import 'package:flutter/material.dart';

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
      label: 'Narration caption',
      value: text,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: QInvWeb3Tokens.cardBgDropdown,
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusCard),
          border: Border.all(color: QInvWeb3Tokens.border),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: QInvWeb3Tokens.textSecondary,
                    height: 1.35,
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
                        icon: const Icon(Icons.replay_rounded),
                        color: QInvWeb3Tokens.primaryLight,
                        onPressed: onReplay,
                        tooltip: 'Replay narration',
                      ),
                    ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: caption,
                  ),
                ),
                if (onReplay != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.replay_rounded),
                    color: QInvWeb3Tokens.primaryLight,
                    onPressed: onReplay,
                    tooltip: 'Replay narration',
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
