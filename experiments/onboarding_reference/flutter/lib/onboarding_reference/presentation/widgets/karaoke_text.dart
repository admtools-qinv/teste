import 'package:flutter/material.dart';

import '../../data/voice_timestamps.dart';
import '../../theme/qinvweb3_tokens.dart';

class KaraokeText extends StatelessWidget {
  final List<WordTiming> timings;
  final Stream<int> positionMsStream;

  const KaraokeText({
    super.key,
    required this.timings,
    required this.positionMsStream,
  });

  int _activeIndexFor(int posMs) {
    if (posMs < 0) return -1;
    for (int i = 0; i < timings.length; i++) {
      if (posMs >= timings[i].startMs && posMs < timings[i].endMs) return i;
      // Between words (gap): keep previous word highlighted.
      if (i < timings.length - 1 &&
          posMs >= timings[i].endMs &&
          posMs < timings[i + 1].startMs) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: positionMsStream.map(_activeIndexFor).distinct(),
      initialData: -1,
      builder: (context, snapshot) {
        final activeIndex = snapshot.data ?? -1;

        return RichText(
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: QInvWeb3Tokens.fontUI,
              fontSize: 12,
              color: QInvWeb3Tokens.textMuted,
              height: 1.50,
            ),
            children: [
              for (int i = 0; i < timings.length; i++) ...[
                if (i > 0) const TextSpan(text: ' '),
                TextSpan(
                  text: timings[i].word,
                  style: i == activeIndex
                      ? TextStyle(
                          color: QInvWeb3Tokens.textHeading,
                          backgroundColor:
                              QInvWeb3Tokens.primary.withValues(alpha: 0.30),
                        )
                      : i < activeIndex
                          ? const TextStyle(color: QInvWeb3Tokens.textHeading)
                          : null,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
