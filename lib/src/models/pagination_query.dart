/// Represents the parameters for a pagination request.
class PaginationQuery {
  /// The current page number (used in page-based pagination).
  final int? page;

  /// The cursor for the next page (used in cursor-based pagination).
  final String? cursor;

  /// The current search query string.
  final String? searchQuery;

  /// Extra filters applied to the request.
  final Map<String, dynamic>? filters;

  PaginationQuery({
    this.page,
    this.cursor,
    this.searchQuery,
    this.filters,
  });

  PaginationQuery copyWith({
    int? page,
    String? cursor,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) {
    return PaginationQuery(
      page: page ?? this.page,
      cursor: cursor ?? this.cursor,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
    );
  }
}
