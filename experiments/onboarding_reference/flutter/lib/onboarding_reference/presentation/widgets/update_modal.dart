import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/qinvweb3_tokens.dart';
import 'slide_to_update_slider.dart';

/// Shows the update modal as a bottom sheet.
///
/// ```dart
/// await showUpdateModal(
///   context: context,
///   onUpdate: () => launchUrl(storeUri),
/// );
/// ```
Future<void> showUpdateModal({
  required BuildContext context,
  String title = 'Hora de atualizar',
  String description =
      'Seu app QInvWeb3 ficou ainda melhor. '
      'Melhoramos a performance e corrigimos '
      'problemas para uma experiência mais fluida.',
  VoidCallback? onUpdate,
  VoidCallback? onDismiss,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (_) => UpdateModal(
      title: title,
      description: description,
      onUpdate: onUpdate,
      onDismiss: onDismiss,
    ),
  );
}

/// Light-surface modal with a "slide to update" gesture.
class UpdateModal extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onUpdate;
  final VoidCallback? onDismiss;

  const UpdateModal({
    super.key,
    required this.title,
    required this.description,
    this.onUpdate,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF4F4F8)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: bottomPad + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar + close button
              _HandleRow(
                onClose: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
              ),

              const SizedBox(height: 24),

              // Upgrade icon
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [QInvWeb3Tokens.primary, QInvWeb3Tokens.primaryLight],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontSerif,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeBody,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666870),
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 32),

              // Slider
              SlideToUpdateSlider(
                onCompleted: () {
                  Navigator.of(context).pop();
                  onUpdate?.call();
                },
              )
                  .animate(delay: 180.ms)
                  .slideY(
                    begin: 0.06,
                    end: 0,
                    duration: 340.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: 280.ms),
            ],
          )
              .animate()
              .slideY(
                begin: 0.04,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: 350.ms),
        ),
      ),
    );
  }
}

class _HandleRow extends StatelessWidget {
  final VoidCallback onClose;
  const _HandleRow({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Centered drag handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Close button on the right
        Positioned(
          right: -8,
          child: IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              size: 24,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }
}
