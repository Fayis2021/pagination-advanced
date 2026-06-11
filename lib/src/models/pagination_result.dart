class PaginationResult<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  /// Optional total count of all items across all pages.
  /// Useful for displaying "Showing X of Y results".
  final int? totalCount;

  PaginationResult({
    required this.items,
    this.nextCursor,
    required this.hasMore,
    this.totalCount,
  });
}
