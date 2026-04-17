import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/qinvweb3_tokens.dart';

class PinInputWidget extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onComplete;

  const PinInputWidget({
    super.key,
    this.enabled = true,
    this.onChanged,
    this.onComplete,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String get _digits => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {});
    HapticFeedback.selectionClick();
    widget.onChanged?.call(text);
    if (text.length == 6) {
      Future.microtask(() => widget.onComplete?.call(text));
    }
  }

  void _ensureFocus() {
    if (!_focusNode.hasFocus && widget.enabled) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // TextField invisível que aciona o teclado nativo
        SizedBox(
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.dark,
              enableIMEPersonalizedLearning: false,
              autocorrect: false,
              enableSuggestions: false,
              obscureText: true,
              enabled: widget.enabled,
              maxLength: 6,
              cursorWidth: 0,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: Colors.transparent,
                fontSize: 1,
                height: 0.01,
              ),
            ),
          ),
        ),
        // Dots — tap para re-abrir teclado
        GestureDetector(
          onTap: _ensureFocus,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildDots(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final filled = i < _digits.length;
        return AnimatedContainer(
          duration: QInvWeb3Tokens.transitionFast,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? QInvWeb3Tokens.primaryLight
                : Colors.transparent,
            border: Border.all(
              color: filled
                  ? QInvWeb3Tokens.primaryLight
                  : Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}
