import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A "slide to update" slider widget inspired by OKX's update prompt.
///
/// The user drags a circular thumb from left to right along a pill-shaped
/// track. When the drag reaches ≥ 88 % of the track width, [onCompleted]
/// fires. If released before that threshold the thumb snaps back with an
/// elastic animation.
///
/// ```dart
/// SlideToUpdateSlider(
///   onCompleted: () => print('update triggered'),
/// )
/// ```
class SlideToUpdateSlider extends StatefulWidget {
  final VoidCallback onCompleted;
  final String label;

  const SlideToUpdateSlider({
    super.key,
    required this.onCompleted,
    this.label = 'Deslize para atualizar',
  });

  @override
  State<SlideToUpdateSlider> createState() => _SlideToUpdateSliderState();
}

class _SlideToUpdateSliderState extends State<SlideToUpdateSlider>
    with SingleTickerProviderStateMixin {
  static const double _height = 64.0;
  static const double _thumbSize = 52.0;
  static const double _thumbPadding = 6.0;

  static const _trackColor = Color(0xFFF0F0F5);
  static const _thumbColor = Color(0xFF111111);
  static const _fillColor = Color(0xFF7D39EB); // QInvWeb3Tokens.primary

  double _dragX = 0.0;
  bool _completed = false;

  late final AnimationController _snapController;
  Animation<double>? _snapAnim;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  double _maxDragX(double trackWidth) =>
      trackWidth - _thumbSize - _thumbPadding * 2;

  double _progress(double trackWidth) {
    final max = _maxDragX(trackWidth);
    return max <= 0 ? 0 : (_dragX / max).clamp(0.0, 1.0);
  }

  void _onDragStart(DragStartDetails _) {
    _snapController.stop();
    _removeSnapListener();
  }

  void _onDragUpdate(DragUpdateDetails d, double trackWidth) {
    if (_completed) return;
    setState(() {
      _dragX = (_dragX + d.delta.dx).clamp(0.0, _maxDragX(trackWidth));
    });

    if (_progress(trackWidth) >= 0.88) {
      _complete(trackWidth);
    }
  }

  void _onDragEnd(DragEndDetails _, double trackWidth) {
    if (_completed) return;
    _snapBack();
  }

  void _complete(double trackWidth) {
    if (_completed) return;
    _completed = true;
    HapticFeedback.mediumImpact();
    Future.delayed(
      const Duration(milliseconds: 80),
      HapticFeedback.heavyImpact,
    );

    // Animate thumb to end
    _removeSnapListener();
    final target = _maxDragX(trackWidth);
    _snapAnim = Tween<double>(begin: _dragX, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapAnim!.addListener(_onSnapTick);
    _snapController.forward(from: 0).then((_) {
      if (mounted) widget.onCompleted();
    });
  }

  void _snapBack() {
    _removeSnapListener();
    _snapAnim = Tween<double>(begin: _dragX, end: 0.0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
    );
    _snapAnim!.addListener(_onSnapTick);
    _snapController.forward(from: 0);
  }

  void _removeSnapListener() {
    _snapAnim?.removeListener(_onSnapTick);
    _snapAnim = null;
  }

  void _onSnapTick() {
    if (_snapAnim != null) {
      setState(() => _dragX = _snapAnim!.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final progress = _progress(trackWidth);
        final labelOpacity = (1.0 - progress * 1.8).clamp(0.0, 1.0);

        return GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
          onHorizontalDragEnd: (d) => _onDragEnd(d, trackWidth),
          child: SizedBox(
            height: _height,
            width: trackWidth,
            child: Stack(
              children: [
                // Track background
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _trackColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ),

                // Progress fill
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _thumbPadding + _thumbSize / 2 + _dragX,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _fillColor.withValues(alpha: 0.10),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),

                // Label
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: _thumbSize),
                    child: Opacity(
                      opacity: labelOpacity,
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: 'packages/onboarding_reference/PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                ),

                // Thumb
                Positioned(
                  left: _thumbPadding + _dragX,
                  top: (_height - _thumbSize) / 2,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: _thumbColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
