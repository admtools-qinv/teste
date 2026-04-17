import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../theme/qinvweb3_tokens.dart';

class AnalysingContent extends StatefulWidget {
  final VoidCallback onComplete;
  const AnalysingContent({super.key, required this.onComplete});

  @override
  State<AnalysingContent> createState() => _AnalysingContentState();
}

class _AnalysingContentState extends State<AnalysingContent>
    with SingleTickerProviderStateMixin {
  static const _messageCount = 4;

  static List<String> _messages(AppLocalizations l10n) => [
    l10n.analysingExperience,
    l10n.analysingGoals,
    l10n.analysingRisk,
    l10n.analysingProfile,
  ];

  static const _totalDuration = Duration(milliseconds: 4500);

  late final AnimationController _ctrl;
  late final Animation<double> _progress;
  int _msgIndex = 0;
  Timer? _msgTimer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _totalDuration);
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    _msgTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      if (!mounted) return;
      setState(() => _msgIndex = (_msgIndex + 1) % _messageCount);
    });

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_done) {
        _done = true;
        _msgTimer?.cancel();
        Future.delayed(QInvWeb3Tokens.transitionMedium, () {
          if (mounted) widget.onComplete();
        });
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _msgTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messages(context.l10n);
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final pct = (_progress.value * 100).round();
        return Column(
          children: [
            const SizedBox(height: 32),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _progress.value,
                      strokeWidth: 4.0,
                      backgroundColor:
                          QInvWeb3Tokens.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        QInvWeb3Tokens.primaryLight,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontFamily: QInvWeb3Tokens.fontUI,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: QInvWeb3Tokens.textHeading,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: QInvWeb3Tokens.transitionMedium,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              ),
              child: Text(
                messages[_msgIndex],
                key: ValueKey<int>(_msgIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: QInvWeb3Tokens.fontUI,
                  fontSize: QInvWeb3Tokens.fontSizeSubtitle,
                  fontWeight: FontWeight.w500,
                  color: QInvWeb3Tokens.textMuted,
                  height: 1.55,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
