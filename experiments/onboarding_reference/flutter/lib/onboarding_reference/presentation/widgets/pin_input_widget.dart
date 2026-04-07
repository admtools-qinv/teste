import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/qinvweb3_tokens.dart';

class PinInputWidget extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onComplete;

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
  String _digits = '';

  void _addDigit(String digit) {
    if (!widget.enabled || _digits.length >= 6) return;
    setState(() => _digits += digit);
    widget.onChanged?.call(_digits);
    if (_digits.length == 6) {
      Future.microtask(() => widget.onComplete?.call());
    }
  }

  void _removeDigit() {
    if (!widget.enabled || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
    widget.onChanged?.call(_digits);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildDots(),
        const SizedBox(height: 32),
        _buildKeypad(),
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
          duration: const Duration(milliseconds: 150),
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

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeyRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildKeyRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildKeyRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildKeyRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitKey(d)).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(width: 80, height: 64),
        _buildDigitKey('0'),
        _buildBackspaceKey(),
      ],
    );
  }

  Widget _buildDigitKey(String digit) {
    return _KeyButton(
      onTap: widget.enabled ? () => _addDigit(digit) : null,
      child: Text(
        digit,
        style: const TextStyle(
          fontFamily: QInvWeb3Tokens.fontUI,
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: QInvWeb3Tokens.textHeading,
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return _KeyButton(
      onTap: widget.enabled ? _removeDigit : null,
      child: const Icon(
        Icons.backspace_outlined,
        color: QInvWeb3Tokens.textSecondary,
        size: 22,
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _KeyButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      child: Container(
        width: 80,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.07),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
