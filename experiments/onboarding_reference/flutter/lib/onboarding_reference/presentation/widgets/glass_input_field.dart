import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/qinvweb3_tokens.dart';

/// Campo de texto com efeito glass (blur + borda animada ao focar).
///
/// Usado em [EmailPasswordScreen], [SignInSheet] e qualquer outro
/// formulário que precise do visual glass do design system Qinv.
class GlassInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool autocorrect;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const GlassInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.autocorrect = true,
    this.onSubmitted,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<GlassInputField> createState() => _GlassInputFieldState();
}

class _GlassInputFieldState extends State<GlassInputField> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _hasFocus = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasFocus
        ? QInvWeb3Tokens.primaryLight.withValues(alpha: 0.60)
        : Colors.white.withValues(alpha: 0.10);

    return AnimatedContainer(
      duration: QInvWeb3Tokens.transitionFast,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: QInvWeb3Tokens.primary.withValues(alpha: 0.20),
                  blurRadius: QInvWeb3Tokens.blurGlass,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              enabled: widget.enabled,
              autocorrect: widget.autocorrect,
              onSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              keyboardAppearance: Brightness.dark,
              style: const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: QInvWeb3Tokens.fontSizeInput,
                fontWeight: FontWeight.w400,
                color: QInvWeb3Tokens.textHeading,
                height: 1.25,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                suffixIcon: widget.suffixIcon,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                labelStyle: TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeSubtitle,
                  color: _hasFocus
                      ? QInvWeb3Tokens.primaryLight.withValues(alpha: 0.90)
                      : QInvWeb3Tokens.textMuted,
                ),
                hintStyle: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeInput,
                  color: QInvWeb3Tokens.textMuted,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Handle bar padrão para bottom sheets.
class QInvHandleBar extends StatelessWidget {
  const QInvHandleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
