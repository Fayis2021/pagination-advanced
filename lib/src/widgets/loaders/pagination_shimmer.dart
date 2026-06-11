import 'package:flutter/material.dart';

/// Controls the style of the initial full-screen loading indicator.
enum PaginationLoadingType {
  /// A centered [CircularProgressIndicator]. (default)
  circular,

  /// A centered [LinearProgressIndicator].
  linear,

  /// A built-in shimmer skeleton (avatar + text rows for list, card boxes for
  /// grid). Customize colors with [shimmerBaseColor] / [shimmerHighlightColor].
  shimmer,

  /// Similar to [shimmer] but uses card-style skeleton blocks instead of
  /// avatar+text rows. Good for card-based UIs.
  skeleton,

  /// Items fade in with [AnimatedOpacity] as the page loads.
  fadein,

  /// A custom widget supplied via the widget's [shimmerBuilder] prop.
  custom,
}

// ─────────────────────────────────────────────────────────────────────────────
// Core shimmer engine
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps any [child] widget with a sliding shimmer gradient animation.
///
/// Use [PaginationShimmerEffect] when you want to apply the shimmer effect
/// to your own custom skeleton layout.
///
/// ### Example
/// ```dart
/// PaginationShimmerEffect(
///   baseColor: Colors.grey.shade300,
///   highlightColor: Colors.grey.shade100,
///   child: MyCustomSkeletonWidget(),
/// )
/// ```
class PaginationShimmerEffect extends StatefulWidget {
  final Widget child;

  /// The base (dark) shimmer color.
  final Color baseColor;

  /// The highlight (light) shimmer color.
  final Color highlightColor;

  /// Duration of one shimmer cycle. Defaults to 1500 ms.
  final Duration duration;

  const PaginationShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PaginationShimmerEffect> createState() =>
      _PaginationShimmerEffectState();
}

class _PaginationShimmerEffectState extends State<PaginationShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform:
                  _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Built-in shimmer skeletons – ListView
// ─────────────────────────────────────────────────────────────────────────────

/// Default shimmer skeleton for [PaginatedListView].
///
/// Renders 6 avatar + two-line-text placeholder rows wrapped in a shimmer.
class DefaultListShimmer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Color baseColor;
  final Color highlightColor;

  /// Number of skeleton rows to show. Defaults to 6.
  final int itemCount;

  const DefaultListShimmer({
    super.key,
    this.padding,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return PaginationShimmerEffect(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        itemCount: itemCount,
        padding: padding ?? const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Built-in card skeleton (skeleton loading type)
// ─────────────────────────────────────────────────────────────────────────────

/// A card-style skeleton shimmer, ideal for card-based list UIs.
///
/// Each placeholder looks like a card with a large image area at the top and
/// two lines of text below.
class DefaultCardShimmer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Color baseColor;
  final Color highlightColor;

  /// Number of skeleton cards to show. Defaults to 4.
  final int itemCount;

  const DefaultCardShimmer({
    super.key,
    this.padding,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return PaginationShimmerEffect(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        itemCount: itemCount,
        padding: padding ?? const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 180,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Built-in shimmer skeletons – GridView
// ─────────────────────────────────────────────────────────────────────────────

/// Default shimmer skeleton for [PaginatedGridView].
class DefaultGridShimmer extends StatelessWidget {
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final Color baseColor;
  final Color highlightColor;

  /// Number of skeleton grid cells to show. Defaults to 8.
  final int itemCount;

  const DefaultGridShimmer({
    super.key,
    required this.gridDelegate,
    this.padding,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return PaginationShimmerEffect(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        gridDelegate: gridDelegate,
        itemCount: itemCount,
        padding: padding ?? const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Built-in shimmer skeletons – SliverList
// ─────────────────────────────────────────────────────────────────────────────

/// Default shimmer skeleton for [PaginatedSliverList].
class DefaultSliverListShimmer extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  /// Number of skeleton rows to show. Defaults to 5.
  final int itemCount;

  const DefaultSliverListShimmer({
    super.key,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return PaginationShimmerEffect(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}
