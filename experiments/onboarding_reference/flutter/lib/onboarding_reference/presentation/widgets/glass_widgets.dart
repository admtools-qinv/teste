import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/qinvweb3_tokens.dart';

@immutable
class GlassOrb {
  final Alignment alignment;
  final double size;
  final Color color;
  final double blurRadius;
  final Offset offset;

  const GlassOrb({
    required this.alignment,
    required this.size,
    required this.color,
    required this.blurRadius,
    this.offset = Offset.zero,
  });
}

const kDefaultOrbs = <GlassOrb>[
  GlassOrb(
    alignment: Alignment(-1.08, -1.0),
    size: 320,
    color: Color(0xFF9F7AEA),
    blurRadius: 78,
    offset: Offset(-18, -12),
  ),
  GlassOrb(
    alignment: Alignment(1.10, -0.78),
    size: 240,
    color: Color(0xFF60A5FA),
    blurRadius: 64,
    offset: Offset(24, -4),
  ),
  GlassOrb(
    alignment: Alignment(-0.92, 0.84),
    size: 340,
    color: Color(0xFF7C3AED),
    blurRadius: 88,
    offset: Offset(-8, 30),
  ),
  GlassOrb(
    alignment: Alignment(0.95, 0.95),
    size: 180,
    color: Color(0xFFF472B6),
    blurRadius: 48,
    offset: Offset(10, 18),
  ),
];

class GlassBackground extends StatefulWidget {
  final Widget child;
  final List<GlassOrb> orbs;
  final Color baseColor;

  const GlassBackground({
    super.key,
    required this.child,
    this.orbs = kDefaultOrbs,
    this.baseColor = QInvWeb3Tokens.background,
  });

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: widget.baseColor,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                const Color(0xFF121827),
                widget.baseColor.withValues(alpha: 0.97),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value * 2 * pi;
                return Stack(
                  children: [
                    for (int i = 0; i < widget.orbs.length; i++)
                      _AnimatedOrb(orb: widget.orbs[i], t: t, index: i),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _AnimatedOrb extends StatelessWidget {
  final GlassOrb orb;
  final double t;
  final int index;

  const _AnimatedOrb({required this.orb, required this.t, required this.index});

  @override
  Widget build(BuildContext context) {
    final phase = index * pi / 2.0;
    final dx = orb.offset.dx + sin(t + phase) * 45;
    final dy = orb.offset.dy + cos(2 * t + phase) * 35;

    return Align(
      alignment: orb.alignment,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: _GlassOrbSurface(orb: orb),
      ),
    );
  }
}

class _GlassOrbSurface extends StatelessWidget {
  final GlassOrb orb;

  const _GlassOrbSurface({required this.orb});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: orb.blurRadius, sigmaY: orb.blurRadius),
      child: Container(
        width: orb.size,
        height: orb.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              orb.color.withValues(alpha: 0.92),
              orb.color.withValues(alpha: 0.28),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final double blurSigma;
  final Color fillColor;
  final Color borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = const BorderRadius.all(Radius.circular(QInvWeb3Tokens.radiusCard)),
    this.blurSigma = 24,
    this.fillColor = const Color.fromRGBO(17, 18, 24, 0.28),
    this.borderColor = const Color.fromRGBO(255, 255, 255, 0.12),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.32, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color accentColor;
  final bool busy;
  final bool selected;
  final bool outline;
  final double height;
  final EdgeInsetsGeometry padding;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.accentColor = QInvWeb3Tokens.primary,
    this.busy = false,
    this.selected = false,
    this.outline = false,
    this.height = 52,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final borderRadius = BorderRadius.circular(999);
    final spinnerColor = outline ? accentColor : QInvWeb3Tokens.primaryForeground;
    final foreground = outline ? accentColor : QInvWeb3Tokens.primaryForeground;

    final content = AnimatedSwitcher(
      duration: QInvWeb3Tokens.transitionAll,
      child: busy
          ? Row(
              key: const ValueKey('busy'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Row(
              key: const ValueKey('idle'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  Icon(Icons.check_circle_rounded, size: 18, color: foreground),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    final decoration = BoxDecoration(
      borderRadius: borderRadius,
      gradient: outline
          ? LinearGradient(
              colors: [
                accentColor.withValues(alpha: selected ? 0.22 : 0.12),
                accentColor.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                accentColor,
                accentColor.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      border: Border.all(
        color: outline
            ? accentColor.withValues(alpha: selected ? 0.72 : 0.45)
            : Colors.white.withValues(alpha: 0.12),
        width: selected ? 1.4 : 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: outline ? 0.08 : 0.26),
          blurRadius: outline ? 16 : 24,
          spreadRadius: outline ? 0 : 1,
          offset: const Offset(0, 10),
        ),
      ],
    );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.mediumImpact();
                onPressed!();
              }
            : null,
        borderRadius: borderRadius,
        child: AnimatedOpacity(
          duration: QInvWeb3Tokens.transitionAll,
          opacity: enabled ? 1 : 0.62,
          child: Container(
            constraints: BoxConstraints(minHeight: height),
            padding: padding,
            decoration: decoration,
            child: Center(
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: label,
      value: busy ? 'Loading' : (selected ? 'Selected' : null),
      child: button,
    );
  }
}
