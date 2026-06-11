import 'package:flutter/material.dart';
import '../controllers/pagination_controller.dart';
import '../models/pagination_state.dart';
import '../models/pagination_theme.dart';
import 'loaders/pagination_shimmer.dart';
import 'paginated_builder.dart';

/// A paginated grid view with built-in infinite scroll, pull-to-refresh,
/// shimmer/skeleton loading, error handling, search, and filter support.
///
/// ### Minimal usage
/// ```dart
/// PaginatedGridView<Product>(
///   fetch: (query) => api.getProducts(query),
///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///     crossAxisCount: 2,
///     childAspectRatio: 0.75,
///   ),
///   itemBuilder: (context, product) => ProductCard(product),
/// )
/// ```
class PaginatedGridView<T> extends StatelessWidget {
  // ── Data ────────────────────────────────────────────────────────────────

  final FetchData<T>? fetch;
  final PaginationController<T>? controller;

  // ── Item builder ────────────────────────────────────────────────────────

  final Widget Function(BuildContext context, T item) itemBuilder;
  final SliverGridDelegate gridDelegate;

  // ── State builders ──────────────────────────────────────────────────────

  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? errorBuilder;

  /// Fully custom shimmer widget shown during the initial load.
  final WidgetBuilder? shimmerBuilder;

  /// Widget shown in the footer while loading the next page.
  final WidgetBuilder? loadingMoreBuilder;

  /// Widget shown after the last item when all pages have been loaded.
  final WidgetBuilder? endOfListBuilder;

  // ── Loading style ───────────────────────────────────────────────────────

  final PaginationLoadingType loadingType;

  // ── Shimmer colors ──────────────────────────────────────────────────────

  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  // ── Refresh ─────────────────────────────────────────────────────────────

  final bool enableRefresh;
  final Color? refreshIndicatorColor;
  final Color? refreshBackgroundColor;

  // ── Scroll ──────────────────────────────────────────────────────────────

  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? scrollPhysics;
  final bool reverse;
  final bool shrinkWrap;

  // ── Theme ────────────────────────────────────────────────────────────────

  final PaginationTheme? theme;

  const PaginatedGridView({
    super.key,
    this.fetch,
    this.controller,
    required this.itemBuilder,
    required this.gridDelegate,
    this.emptyBuilder,
    this.errorBuilder,
    this.shimmerBuilder,
    this.loadingMoreBuilder,
    this.endOfListBuilder,
    this.loadingType = PaginationLoadingType.circular,
    this.shimmerBaseColor = const Color(0xFFE0E0E0),
    this.shimmerHighlightColor = const Color(0xFFF5F5F5),
    this.enableRefresh = true,
    this.refreshIndicatorColor,
    this.refreshBackgroundColor,
    this.padding,
    this.scrollPhysics,
    this.reverse = false,
    this.shrinkWrap = false,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ?? const PaginationTheme();

    return PaginatedBuilder<T>(
      fetch: fetch,
      controller: controller,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      shimmerBuilder: shimmerBuilder,
      loadingType: loadingType,
      enableRefresh: enableRefresh,
      refreshIndicatorColor:
          refreshIndicatorColor ?? resolvedTheme.refreshIndicatorColor,
      refreshBackgroundColor:
          refreshBackgroundColor ?? resolvedTheme.refreshBackgroundColor,
      theme: resolvedTheme,
      defaultShimmerBuilder: (context) {
        final base = shimmerBaseColor != const Color(0xFFE0E0E0)
            ? shimmerBaseColor
            : resolvedTheme.shimmerBaseColor;
        final highlight = shimmerHighlightColor != const Color(0xFFF5F5F5)
            ? shimmerHighlightColor
            : resolvedTheme.shimmerHighlightColor;
        return DefaultGridShimmer(
          gridDelegate: gridDelegate,
          padding: padding,
          baseColor: base,
          highlightColor: highlight,
        );
      },
      builder: (context, state, scrollController, internalController) {
        final effectivePhysics =
            scrollPhysics ?? const AlwaysScrollableScrollPhysics();

        Widget buildFooter() {
          if (state.status == PaginationStatus.error) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error loading more: ${state.error}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: internalController.retry,
                    style: resolvedTheme.retryButtonStyle,
                    child: Text(resolvedTheme.retryLabel),
                  ),
                ],
              ),
            );
          }
          if (loadingMoreBuilder != null) return loadingMoreBuilder!(context);
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        Widget buildEndOfList() {
          if (endOfListBuilder != null) return endOfListBuilder!(context);
          if (resolvedTheme.endOfListLabel.isEmpty) return const SizedBox();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                resolvedTheme.endOfListLabel,
                style: resolvedTheme.endOfListTextStyle ??
                    Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
              ),
            ),
          );
        }

        return CustomScrollView(
          controller: scrollController,
          physics: effectivePhysics,
          reverse: reverse,
          shrinkWrap: shrinkWrap,
          slivers: [
            SliverPadding(
              padding: padding ?? EdgeInsets.zero,
              sliver: SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      itemBuilder(context, state.items[index]),
                  childCount: state.items.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: state.hasMore ? buildFooter() : buildEndOfList(),
            ),
          ],
        );
      },
    );
  }
}
