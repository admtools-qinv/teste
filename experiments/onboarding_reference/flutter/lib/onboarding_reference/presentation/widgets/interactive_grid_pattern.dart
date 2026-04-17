import 'dart:math';

import 'package:flutter/material.dart';

/// A full-screen grid of squares with 3 ghost cursors drifting automatically.
///
/// Reproduces the React `InteractiveGridPattern` — cursors move randomly and
/// light up cells with a smooth fade in/out transition.
class InteractiveGridPattern extends StatefulWidget {
  final double squareSize;
  final Color gridColor;
  final Color activeColor;

  const InteractiveGridPattern({
    super.key,
    this.squareSize = 40,
    this.gridColor = const Color.fromRGBO(255, 255, 255, 0.07),
    this.activeColor = const Color.fromRGBO(255, 255, 255, 0.08),
  });

  @override
  State<InteractiveGridPattern> createState() => _InteractiveGridPatternState();
}

class _InteractiveGridPatternState extends State<InteractiveGridPattern>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final _rng = Random();

  final List<_GhostCursor> _cursors = [];
  final Map<int, double> _activeOpacities = {};
  int _numX = 0;
  int _numY = 0;
  int _lastMs = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _anim.addListener(_onTick);
  }

  void _ensureGrid(BoxConstraints constraints) {
    final newX = (constraints.maxWidth / widget.squareSize).ceil();
    final newY = (constraints.maxHeight / widget.squareSize).ceil();
    if (newX == _numX && newY == _numY) return;
    _numX = newX;
    _numY = newY;
    _activeOpacities.clear();
    _cursors
      ..clear()
      ..addAll([
        _GhostCursor((_numX * 0.2).floor(), (_numY * 0.3).floor(), 300),
        _GhostCursor((_numX * 0.5).floor(), (_numY * 0.6).floor(), 380),
        _GhostCursor((_numX * 0.8).floor(), (_numY * 0.2).floor(), 460),
      ]);
  }

  void _onTick() {
    if (_numX == 0 || _numY == 0) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastMs == 0) _lastMs = now;

    bool dirty = false;

    // Move cursors on their individual intervals
    for (final c in _cursors) {
      if (now - c.lastMove >= c.interval) {
        c.lastMove = now;
        c.col = (c.col + ((_rng.nextDouble() - 0.5) * 5).round())
            .clamp(0, _numX - 1);
        c.row = (c.row + ((_rng.nextDouble() - 0.5) * 5).round())
            .clamp(0, _numY - 1);
        dirty = true;
      }
    }

    // Build set of currently active cell indices
    final targets = {for (final c in _cursors) c.row * _numX + c.col};

    // Fade in active cells
    for (final idx in targets) {
      _activeOpacities[idx] =
          ((_activeOpacities[idx] ?? 0.0) + 0.08).clamp(0.0, 1.0);
      dirty = true;
    }

    // Fade out inactive cells
    final toRemove = <int>[];
    for (final e in _activeOpacities.entries) {
      if (!targets.contains(e.key)) {
        _activeOpacities[e.key] = e.value - 0.03;
        if (e.value <= 0) toRemove.add(e.key);
        dirty = true;
      }
    }
    for (final k in toRemove) {
      _activeOpacities.remove(k);
    }

    _lastMs = now;
    if (dirty) setState(() {});
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _ensureGrid(constraints);

        return ShaderMask(
          shaderCallback: (bounds) => const RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Colors.white, Colors.white, Colors.white10, Colors.transparent],
            stops: [0.0, 0.65, 0.85, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _GridPainter(
                squareSize: widget.squareSize,
                numX: _numX,
                numY: _numY,
                gridColor: widget.gridColor,
                activeColor: widget.activeColor,
                activeOpacities: _activeOpacities,
              ),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        );
      },
    );
  }
}

class _GhostCursor {
  int col, row;
  final int interval;
  int lastMove = 0;
  _GhostCursor(this.col, this.row, this.interval);
}

class _GridPainter extends CustomPainter {
  final double squareSize;
  final int numX, numY;
  final Color gridColor, activeColor;
  final Map<int, double> activeOpacities;

  _GridPainter({
    required this.squareSize,
    required this.numX,
    required this.numY,
    required this.gridColor,
    required this.activeColor,
    required this.activeOpacities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int x = 0; x <= numX; x++) {
      final dx = x * squareSize;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), linePaint);
    }
    for (int y = 0; y <= numY; y++) {
      final dy = y * squareSize;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), linePaint);
    }

    if (activeOpacities.isEmpty) return;
    final fill = Paint()..style = PaintingStyle.fill;
    for (final e in activeOpacities.entries) {
      final row = e.key ~/ numX;
      final col = e.key % numX;
      fill.color = activeColor.withValues(
          alpha: activeColor.a * e.value.clamp(0.0, 1.0));
      canvas.drawRect(
        Rect.fromLTWH(
            col * squareSize, row * squareSize, squareSize, squareSize),
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => true;
}
