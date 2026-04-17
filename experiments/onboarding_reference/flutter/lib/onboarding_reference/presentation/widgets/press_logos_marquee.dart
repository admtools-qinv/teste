import 'package:flutter/material.dart';

import '../../theme/qinvweb3_tokens.dart';

class PressLogosMarquee extends StatelessWidget {
  const PressLogosMarquee({super.key});
  static const _package = 'onboarding_reference';

  static const _pressLogos = [
    'logos/forbes.png',
    'logos/cointelegraph.png',
    'logos/exame.png',
    'logos/infomoney.png',
    'logos/valor.png',
    'logos/istoe.png',
  ];

  // Heights tuned so all logos have similar visual weight in the grid
  static const _logoHeights = <String, double>{
    'logos/forbes.png': 18,
    'logos/cointelegraph.png': 28,
    'logos/exame.png': 14,
    'logos/infomoney.png': 16,
    'logos/valor.png': 20,
    'logos/istoe.png': 20,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: 0.45,
          child: Text(
            'Featured by',
            style: TextStyle(
              color: QInvWeb3Tokens.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (int row = 0; row < 2; row++)
          Padding(
            padding: EdgeInsets.only(bottom: row == 0 ? 14 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 0; col < 3; col++)
                  () {
                    final logo = _pressLogos[row * 3 + col];
                    return Opacity(
                      opacity: 0.5,
                      child: SizedBox(
                        height: _logoHeights[logo] ?? 20,
                        child: Image.asset(
                          'assets/$logo',
                          package: _package,
                          fit: BoxFit.contain,
                          color: QInvWeb3Tokens.textMuted,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                    );
                  }(),
              ],
            ),
          ),
      ],
    );
  }
}
