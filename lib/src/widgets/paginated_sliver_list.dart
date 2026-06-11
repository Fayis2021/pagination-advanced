import 'package:flutter/material.dart';
import '../controllers/pagination_controller.dart';
import '../models/pagination_state.dart';
import 'loaders/pagination_shimmer.dart';

class PaginatedSliverList<T> extends StatefulWidget {
  final FetchData<T>? fetch;
  final PaginationController<T>? controller;
  final Widget Function(BuildContext, T) itemBuilder;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? shimmerBuilder;
  final WidgetBuilder? loadingMoreBuilder;
  final PaginationLoadingType loadingType;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  const PaginatedSliverList({
    super.key,
    this.fetch,
    this.controller,
    required this.itemBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.shimmerBuilder,
    this.loadingMoreBuilder,
    this.loadingType = PaginationLoadingType.circular,
    this.shimmerBaseColor = const Color(0xFFE0E0E0),
    this.shimmerHighlightColor = const Color(0xFFF5F5F5),
  }) : assert(fetch != null || controller != null,
            'Either fetch or controller must be provided');

  @override
  State<PaginatedSliverList<T>> createState() => _PaginatedSliverListState<T>();
}

class _PaginatedSliverListState<T> extends State<PaginatedSliverList<T>> {
  late PaginationController<T> _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = PaginationController<T>(fetch: widget.fetch!);
      _ownsController = true;
    }
  }

  @override
  void didUpdateWidget(PaginatedSliverList<T> oldWidget) {
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
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaginationState<T>>(
      valueListenable: _controller,
      builder: (context, state, _) {
        if (state.status == PaginationStatus.initialLoading) {
          if (widget.shimmerBuilder != null) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => widget.shimmerBuilder!(context),
                childCount: 5,
              ),
            );
          }
          if (widget.loadingType == PaginationLoadingType.shimmer) {
            return DefaultSliverListShimmer(
              baseColor: widget.shimmerBaseColor,
              highlightColor: widget.shimmerHighlightColor,
            );
          }
          if (widget.loadingType == PaginationLoadingType.linear) {
            return const SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(),
                ),
              ),
            );
          }
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == PaginationStatus.error && state.items.isEmpty) {
          if (widget.errorBuilder != null) {
            return SliverToBoxAdapter(child: widget.errorBuilder!(context));
          }
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _controller.retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.items.isEmpty) {
          if (widget.emptyBuilder != null) {
            return SliverToBoxAdapter(child: widget.emptyBuilder!(context));
          }
          return const SliverFillRemaining(
            child: Center(child: Text('No items found.')),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= state.items.length) {
                if (state.status != PaginationStatus.loadingMore &&
                    state.status != PaginationStatus.initialLoading &&
                    state.status != PaginationStatus.error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _controller.fetchMore();
                  });
                }

                if (state.status == PaginationStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Error loading more: ${state.error}'),
                        ElevatedButton(
                          onPressed: _controller.retry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (widget.loadingMoreBuilder != null) {
                  return widget.loadingMoreBuilder!(context);
                }
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return widget.itemBuilder(context, state.items[index]);
            },
            childCount: state.items.length + (state.hasMore ? 1 : 0),
          ),
        );
      },
    );
  }
}
