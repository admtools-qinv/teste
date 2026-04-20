import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n.dart';

class QInvReviewTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const QInvReviewTile({
    super.key,
    required this.label,
    required this.value,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final compact = constraints.maxWidth < 340 || textScale > 1.15;

        final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            );
        final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            );

        final content = compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  const SizedBox(height: 6),
                  Text(value, style: valueStyle),
                ],
              )
            : Row(
                children: [
                  Expanded(child: Text(label, style: labelStyle)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: valueStyle,
                    ),
                  ),
                ],
              );

        return Semantics(
          container: true,
          label: label,
          value: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                content,
                if (onEdit != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onEdit == null
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              onEdit!();
                            },
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(context.l10n.actionEdit),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
