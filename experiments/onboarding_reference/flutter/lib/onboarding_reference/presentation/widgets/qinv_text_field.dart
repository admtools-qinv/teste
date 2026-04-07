import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/qinvweb3_tokens.dart';

class QInvTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? semanticsLabel;
  final String? semanticsHint;
  final TextStyle? textStyle;
  final FocusNode? focusNode;

  const QInvTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.semanticsLabel,
    this.semanticsHint,
    this.textStyle,
    this.focusNode,
  });

  @override
  State<QInvTextField> createState() => _QInvTextFieldState();
}

class _QInvTextFieldState extends State<QInvTextField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: widget.semanticsLabel,
      hint: widget.semanticsHint,
      enabled: widget.enabled,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(QInvWeb3Tokens.radiusInput),
          boxShadow: _hasFocus
              ? [
                  BoxShadow(
                    color: QInvWeb3Tokens.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          keyboardAppearance: Brightness.dark,
          style: widget.textStyle ??
              const TextStyle(
                fontFamily: QInvWeb3Tokens.fontUI,
                fontSize: QInvWeb3Tokens.fontSizeInput,
                fontWeight: FontWeight.w400,
                color: QInvWeb3Tokens.textHeading,
                height: 1.25,
                letterSpacing: 0.1,
              ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
          ),
        ),
      ),
    );
  }
}
