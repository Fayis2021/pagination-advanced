import 'package:flutter/material.dart';
import '../controllers/pagination_controller.dart';
import '../models/pagination_state.dart';
import '../models/pagination_theme.dart';
import 'loaders/pagination_shimmer.dart';
import 'paginated_builder.dart';

/// A paginated list view with built-in infinite scroll, pull-to-refresh,
/// shimmer/skeleton loading, error handling, search, and filter support.
///
/// ### Minimal usage
/// ```dart
/// PaginatedListView<Product>(
///   fetch: (query) => api.getProducts(query),
///   itemBuilder: (context, product) => ProductCard(product),
/// )
/// ```
///
/// ### With all options
/// ```dart
/// PaginatedListView<Product>(
///   fetch: (query) => api.getProducts(query),
///   loadingType: PaginationLoadingType.shimmer,
///   enableRefresh: true,
///   theme: PaginationTheme(
///     shimmerBaseColor: Colors.grey.shade300,
///     refreshIndicatorColor: Colors.deepPurple,
///   ),
///   itemBuilder: (context, product) => ProductCard(product),
///   separatorBuilder: (context, index) => const Divider(),
///   emptyBuilder: (context) => const Center(child: Text('No products')),
///   errorBuilder: (context) => const Center(child: Text('Oops!')),
///   endOfListBuilder: (context) => const Center(child: Text('That\'s all!')),
/// )
/// ```
class PaginatedListView<T> extends StatelessWidget {
  // ── Data ────────────────────────────────────────────────────────────────

  /// Async function called with the current [PaginationQuery].
  /// Required unless [controller] is provided.
  final FetchData<T>? fetch;

  /// Externally managed controller. Useful when you need to call
  /// [PaginationController.search] or [PaginationController.applyFilter]
  /// from outside the widget.
  final PaginationController<T>? controller;

  // ── Item builder ────────────────────────────────────────────────────────

  /// Builds a widget for each item in the list.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Optional separator between items (e.g. `Divider`).
  final IndexedWidgetBuilder? separatorBuilder;

  // ── State builders ──────────────────────────────────────────────────────

  /// Widget shown when the list is empty after a successful load.
  final WidgetBuilder? emptyBuilder;

  /// Widget shown when the initial load fails entirely.
  final WidgetBuilder? errorBuilder;

  /// Fully custom shimmer widget shown during the initial load.
  /// Overrides [loadingType].
  final WidgetBuilder? shimmerBuilder;

  /// Widget shown in the footer while loading the next page.
  /// Defaults to a [CircularProgressIndicator].
  final WidgetBuilder? loadingMoreBuilder;

  /// Widget shown after the last item when all pages have been loaded.
  final WidgetBuilder? endOfListBuilder;

  // ── Loading style ───────────────────────────────────────────────────────

  /// Controls the built-in initial loading indicator style.
  final PaginationLoadingType loadingType;

  // ── Shimmer colors ──────────────────────────────────────────────────────

  /// Base (dark) color of the built-in shimmer. Overrides [theme].
  final Color shimmerBaseColor;

  /// Highlight (light) color of the built-in shimmer. Overrides [theme].
  final Color shimmerHighlightColor;

  // ── Refresh ─────────────────────────────────────────────────────────────

  /// Whether to wrap the list in a [RefreshIndicator]. Defaults to `true`.
  final bool enableRefresh;

  /// Foreground color of the [RefreshIndicator].
  final Color? refreshIndicatorColor;

  /// Background color of the [RefreshIndicator].
  final Color? refreshBackgroundColor;

  // ── Scroll ──────────────────────────────────────────────────────────────

  /// The padding around the list.
  final EdgeInsetsGeometry? padding;

  /// The scroll direction. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction. Defaults to `false`.
  final bool reverse;

  /// Custom scroll physics for the list.
  final ScrollPhysics? scrollPhysics;

  /// Whether the list should shrink-wrap its content. Defaults to `false`.
  final bool shrinkWrap;

  // ── Theme ────────────────────────────────────────────────────────────────

  /// Optional centralized theme. Per-prop values take precedence.
  final PaginationTheme? theme;

  const PaginatedListView({
    super.key,
    this.fetch,
    this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
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
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollPhysics,
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
        if (loadingType == PaginationLoadingType.skeleton) {
          return DefaultCardShimmer(
            padding: padding,
            baseColor: base,
            highlightColor: highlight,
          );
        }
        return DefaultListShimmer(
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

        final itemCount = state.items.length + 1; // +1 for footer/end-of-list

        if (separatorBuilder != null) {
          return ListView.separated(
            controller: scrollController,
            physics: effectivePhysics,
            padding: padding,
            scrollDirection: scrollDirection,
            reverse: reverse,
            shrinkWrap: shrinkWrap,
            itemCount: itemCount,
            separatorBuilder: (context, index) {
              if (index >= state.items.length - 1) return const SizedBox();
              return separatorBuilder!(context, index);
            },
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return state.hasMore ? buildFooter() : buildEndOfList();
              }
              return itemBuilder(context, state.items[index]);
            },
          );
        }

        return ListView.builder(
          controller: scrollController,
          physics: effectivePhysics,
          padding: padding,
          scrollDirection: scrollDirection,
          reverse: reverse,
          shrinkWrap: shrinkWrap,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return state.hasMore ? buildFooter() : buildEndOfList();
            }
            return itemBuilder(context, state.items[index]);
          },
        );
      },
    );
  }
}
