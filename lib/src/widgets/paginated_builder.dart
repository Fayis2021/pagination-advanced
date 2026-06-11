import 'package:flutter/material.dart';
import '../controllers/pagination_controller.dart';
import '../models/pagination_state.dart';
import '../models/pagination_theme.dart';
import 'loaders/pagination_shimmer.dart';

/// The core engine behind all paginated widgets.
///
/// You usually don't need this directly — use [PaginatedListView] or
/// [PaginatedGridView] instead. Use [PaginatedBuilder] when you need a
/// fully custom scroll layout (e.g. a custom [CustomScrollView] with slivers).
class PaginatedBuilder<T> extends StatefulWidget {
  final FetchData<T>? fetch;
  final PaginationController<T>? controller;

  /// Build the scrollable content. Receives the current [PaginationState],
  /// the managed [ScrollController], and the internal [PaginationController].
  final Widget Function(
    BuildContext context,
    PaginationState<T> state,
    ScrollController scrollController,
    PaginationController<T> paginationController,
  ) builder;

  // ── Customizable state builders ─────────────────────────────────────────

  /// Widget shown when the list is empty (after a successful load).
  final WidgetBuilder? emptyBuilder;

  /// Widget shown when a full-page error occurs (initial load fails).
  final WidgetBuilder? errorBuilder;

  /// Fully custom shimmer/skeleton widget shown during the initial load.
  /// Takes precedence over [loadingType].
  final WidgetBuilder? shimmerBuilder;

  // ── Loading style ───────────────────────────────────────────────────────

  /// Controls the built-in initial loading indicator.
  /// Ignored when [shimmerBuilder] is provided.
  final PaginationLoadingType loadingType;

  // ── Refresh ─────────────────────────────────────────────────────────────

  /// Whether to wrap the list in a [RefreshIndicator]. Defaults to `true`.
  final bool enableRefresh;

  /// Foreground color of the [RefreshIndicator] spinning arrow.
  final Color? refreshIndicatorColor;

  /// Background color of the [RefreshIndicator] circle.
  final Color? refreshBackgroundColor;

  // ── Shimmer colors ──────────────────────────────────────────────────────

  /// Builder for the built-in default shimmer (used when
  /// [loadingType] == [PaginationLoadingType.shimmer] or `.skeleton`).
  final WidgetBuilder? defaultShimmerBuilder;

  // ── End of list ─────────────────────────────────────────────────────────

  /// Widget shown at the bottom when all pages have been loaded
  /// (`hasMore == false`).
  final WidgetBuilder? endOfListBuilder;

  // ── Theme ────────────────────────────────────────────────────────────────

  /// Optional centralized theme. Per-prop values take precedence.
  final PaginationTheme? theme;

  const PaginatedBuilder({
    super.key,
    this.fetch,
    this.controller,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
    this.shimmerBuilder,
    this.defaultShimmerBuilder,
    this.loadingType = PaginationLoadingType.circular,
    this.enableRefresh = true,
    this.refreshIndicatorColor,
    this.refreshBackgroundColor,
    this.endOfListBuilder,
    this.theme,
  }) : assert(fetch != null || controller != null,
            'Either fetch or controller must be provided');

  @override
  State<PaginatedBuilder<T>> createState() => _PaginatedBuilderState<T>();
}

class _PaginatedBuilderState<T> extends State<PaginatedBuilder<T>> {
  late PaginationController<T> _controller;
  final ScrollController _scrollController = ScrollController();
  bool _ownsController = false;

  PaginationTheme get _theme => widget.theme ?? const PaginationTheme();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = PaginationController<T>(fetch: widget.fetch!);
      _ownsController = true;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PaginatedBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      if (_ownsController) {
        _controller.dispose();
        _ownsController = false;
      }
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _controller.fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaginationState<T>>(
      valueListenable: _controller,
      builder: (context, state, _) {
        // ── Initial loading ─────────────────────────────────────────────
        if (state.status == PaginationStatus.initialLoading) {
          return _buildInitialLoading(context);
        }

        // ── Full-page error ─────────────────────────────────────────────
        if (state.status == PaginationStatus.error && state.items.isEmpty) {
          return _buildFullError(context, state);
        }

        // ── Empty state ─────────────────────────────────────────────────
        if (state.items.isEmpty) {
          if (widget.emptyBuilder != null) {
            return widget.emptyBuilder!(context);
          }
          return Center(
            child: Text(
              _theme.emptyLabel,
              style: _theme.emptyTextStyle,
            ),
          );
        }

        // ── Main content ────────────────────────────────────────────────
        Widget child =
            widget.builder(context, state, _scrollController, _controller);

        if (widget.enableRefresh) {
          child = RefreshIndicator(
            onRefresh: _controller.refresh,
            color: widget.refreshIndicatorColor ?? _theme.refreshIndicatorColor,
            backgroundColor:
                widget.refreshBackgroundColor ?? _theme.refreshBackgroundColor,
            child: child,
          );
        }

        return child;
      },
    );
  }

  Widget _buildInitialLoading(BuildContext context) {
    // Custom builder wins
    if (widget.shimmerBuilder != null) {
      return widget.shimmerBuilder!(context);
    }
    // Built-in shimmer delegate
    if (widget.defaultShimmerBuilder != null &&
        (widget.loadingType == PaginationLoadingType.shimmer ||
            widget.loadingType == PaginationLoadingType.skeleton)) {
      return widget.defaultShimmerBuilder!(context);
    }
    switch (widget.loadingType) {
      case PaginationLoadingType.linear:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: LinearProgressIndicator(),
          ),
        );
      case PaginationLoadingType.fadein:
        // fadein has no full-page loader; fall through to circular
        return const Center(child: CircularProgressIndicator());
      case PaginationLoadingType.shimmer:
      case PaginationLoadingType.skeleton:
      case PaginationLoadingType.custom:
      case PaginationLoadingType.circular:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildFullError(BuildContext context, PaginationState<T> state) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: _theme.errorTextStyle ??
                Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${state.error}',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _controller.retry,
            style: _theme.retryButtonStyle,
            child: Text(_theme.retryLabel),
          ),
        ],
      ),
    );
  }
}
