import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/qinvweb3_tokens.dart';

class ReviewData {
  final String author;
  final String title;
  final String body;
  final int stars;

  const ReviewData({
    required this.author,
    required this.title,
    required this.body,
    // ignore: unused_element_parameter
    this.stars = 5,
  });
}

class ShowcaseReviews extends StatelessWidget {
  const ShowcaseReviews({super.key});

  static const _row1 = [
    ReviewData(
      author: 'IanCastro',
      title: 'Smart portfolios really work!',
      body:
          "I've tried many brokers, but QINV stood out with its AI. It optimizes my investments strategically and transparently.",
    ),
    ReviewData(
      author: 'Ana B.',
      title: 'Super intuitive!',
      body:
          'I was a crypto beginner and afraid of making mistakes. QINV guided me clearly from my very first investment.',
    ),
    ReviewData(
      author: 'Cla_RR',
      title: 'Easy and practical',
      body:
          "First time investing and couldn't be happier. Easy to invest, track returns, and withdrawals are super fast!",
    ),
  ];

  static const _row2 = [
    ReviewData(
      author: 'Thiagosdep',
      title: 'Effortless investing',
      body:
          'The app helps me invest in diverse cryptos without prior knowledge. It analyzes the market and diversifies for me.',
    ),
    ReviewData(
      author: 'manusilvasilv',
      title: 'Reliable',
      body:
          'First time investing in crypto and it was amazing! Instant withdrawals add real credibility.',
    ),
    ReviewData(
      author: 'Pedro_LF',
      title: 'Best crypto app',
      body:
          'Simple interface, great AI suggestions. I feel confident investing now. Highly recommended!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 174,
          child: InfiniteMarquee(
            velocity: 22,
            itemCount: _row1.length,
            separatorWidth: 12,
            itemBuilder: (index) => ReviewCard(review: _row1[index]),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 174,
          child: InfiniteMarquee(
            velocity: 22,
            reverse: true,
            itemCount: _row2.length,
            separatorWidth: 12,
            itemBuilder: (index) => ReviewCard(review: _row2[index]),
          ),
        ),
      ],
    );
  }
}

// ── Infinite auto-scroll marquee ─────────────────────────────────

class InfiniteMarquee extends StatefulWidget {
  final double velocity; // pixels per second
  final int itemCount;
  final double separatorWidth;
  final bool reverse;
  final Widget Function(int index) itemBuilder;

  const InfiniteMarquee({
    super.key,
    required this.velocity,
    required this.itemCount,
    required this.separatorWidth,
    required this.itemBuilder,
    this.reverse = false,
  });

  @override
  State<InfiniteMarquee> createState() => _InfiniteMarqueeState();
}

class _InfiniteMarqueeState extends State<InfiniteMarquee>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker(_onTick)..start();
  }

  bool _ready = false;

  void _onTick(Duration elapsed) {
    if (!_scrollController.hasClients) {
      _lastTick = elapsed;
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    // For reverse, start from the middle so we scroll left smoothly
    if (!_ready) {
      _ready = true;
      if (widget.reverse) {
        _scrollController.jumpTo(maxScroll / 2);
      }
      _lastTick = elapsed;
      return;
    }

    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;

    final direction = widget.reverse ? -1.0 : 1.0;
    final newOffset =
        _scrollController.offset + widget.velocity * direction * dt;

    // Clamp to bounds — with enough items we never hit the edge
    if (newOffset >= 0 && newOffset <= maxScroll) {
      _scrollController.jumpTo(newOffset);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Render many copies so the scroll never visibly resets
    final totalItems = widget.itemCount * 50;
    return ListView.separated(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalItems,
      separatorBuilder: (_, __) =>
          SizedBox(width: widget.separatorWidth),
      itemBuilder: (_, index) =>
          widget.itemBuilder(index % widget.itemCount),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewData review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '"${review.title}"',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: QInvWeb3Tokens.fontSans,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.30,
            ),
          ),
          const SizedBox(height: 6),
          // Body
          Expanded(
            child: Text(
              review.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: QInvWeb3Tokens.fontSans,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.55),
                height: 1.40,
              ),
            ),
          ),
          // Divider + Author
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            child: Text(
              review.author.toUpperCase(),
              style: TextStyle(
                fontFamily: QInvWeb3Tokens.fontSans,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: Colors.white.withValues(alpha: 0.30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
