enum PaginationStatus {
  initialLoading,
  loaded,
  loadingMore,
  error,
}

class PaginationState<T> {
  final PaginationStatus status;
  final List<T> items;
  final Object? error;
  final bool hasMore;

  /// Total count if provided by the API (e.g. for "Showing X of Y results").
  final int? totalCount;

  PaginationState({
    required this.status,
    required this.items,
    this.error,
    this.hasMore = true,
    this.totalCount,
  });

  PaginationState<T> copyWith({
    PaginationStatus? status,
    List<T>? items,
    Object? error,
    bool? hasMore,
    int? totalCount,
  }) {
    return PaginationState<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  factory PaginationState.initial() => PaginationState(
        status: PaginationStatus.initialLoading,
        items: const [],
      );
}
