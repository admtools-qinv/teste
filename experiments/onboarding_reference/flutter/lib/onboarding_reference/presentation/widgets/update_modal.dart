import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../l10n/l10n.dart';
import '../../theme/qinvweb3_tokens.dart';
import 'slide_to_update_slider.dart';

/// Shows the update modal as a centered glass banner.
///
/// ```dart
/// await showUpdateModal(
///   context: context,
///   onUpdate: () => launchUrl(storeUri),
/// );
/// ```
Future<void> showUpdateModal({
  required BuildContext context,
  String? title,
  String? description,
  VoidCallback? onUpdate,
  VoidCallback? onDismiss,
}) {
  final l10n = AppLocalizations.of(context)!;
  final effectiveTitle = title ?? l10n.updateTitle;
  final effectiveDescription = description ?? l10n.updateDescription;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: l10n.updateDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: QInvWeb3Tokens.transitionModal,
    transitionBuilder: (context, animation, _, child) {
      final curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, _, __) => UpdateModal(
      title: effectiveTitle,
      description: effectiveDescription,
      onUpdate: onUpdate,
      onDismiss: onDismiss,
    ),
  );
}

/// Glass-surface modal with a "slide to update" gesture.
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: QInvWeb3Tokens.blurModal, sigmaY: QInvWeb3Tokens.blurModal),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                            onDismiss?.call();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),

                      // Upgrade icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              QInvWeb3Tokens.primary,
                              QInvWeb3Tokens.primaryLight,
                            ],
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
                          fontFamily: QInvWeb3Tokens.fontUI,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Description
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: QInvWeb3Tokens.fontUI,
                          fontSize: QInvWeb3Tokens.fontSizeBody,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.65),
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
