class PaginationQuery {
  final int? page;
  final String? cursor;
  final String? searchQuery;
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
