import 'package:flutter/foundation.dart';
import '../models/pagination_query.dart';
import '../models/pagination_result.dart';
import '../models/pagination_state.dart';

enum PaginationType { page, cursor }

/// Signature for the data fetching function.
/// Receives a [PaginationQuery] and returns a [PaginationResult].
typedef FetchData<T> = Future<PaginationResult<T>> Function(PaginationQuery query);

/// A controller that manages the state of a paginated list.
///
/// It handles loading initial data, fetching more pages as the user scrolls,
/// refreshing the list, searching, and filtering.
///
/// Use this if you need to control the pagination from outside the widget
/// (e.g. to trigger a search from a text field in the AppBar).
class PaginationController<T> extends ValueNotifier<PaginationState<T>> {
  /// The function used to fetch data.
  final FetchData<T> fetch;

  /// The type of pagination (page-based or cursor-based).
  final PaginationType type;

  /// The first page number to load. Defaults to 1.
  final int initialPage;

  late PaginationQuery _currentQuery;

  PaginationController({
    required this.fetch,
    this.type = PaginationType.page,
    this.initialPage = 1,
    List<T>? initialData,
  }) : super(initialData != null
            ? PaginationState<T>(
                status: PaginationStatus.loaded, items: initialData)
            : PaginationState<T>.initial()) {
    _currentQuery = PaginationQuery(
      page: type == PaginationType.page ? initialPage : null,
    );

    if (initialData == null) {
      loadInitial();
    }
  }

  /// Loads the first page of data.
  ///
  /// Resets the current items and sets the status to [PaginationStatus.initialLoading].
  Future<void> loadInitial() async {
    value =
        value.copyWith(status: PaginationStatus.initialLoading, error: null);
    try {
      final result = await fetch(_currentQuery);
      _updateQueryFromResult(result);

      value = value.copyWith(
        status: PaginationStatus.loaded,
        items: result.items,
        hasMore: result.hasMore,
        totalCount: result.totalCount,
      );
    } catch (e) {
      value = value.copyWith(status: PaginationStatus.error, error: e);
    }
  }

  /// Fetches the next page of data.
  ///
  /// Does nothing if a load is already in progress or if there are no more items.
  Future<void> fetchMore() async {
    if (value.status == PaginationStatus.loadingMore ||
        value.status == PaginationStatus.initialLoading ||
        !value.hasMore) {
      return;
    }

    value = value.copyWith(status: PaginationStatus.loadingMore);

    try {
      final result = await fetch(_currentQuery);
      _updateQueryFromResult(result);

      value = value.copyWith(
        status: PaginationStatus.loaded,
        items: [...value.items, ...result.items],
        hasMore: result.hasMore,
        totalCount: result.totalCount ?? value.totalCount,
        error: null,
      );
    } catch (e) {
      value = value.copyWith(status: PaginationStatus.error, error: e);
    }
  }

  void _updateQueryFromResult(PaginationResult<T> result) {
    if (type == PaginationType.page) {
      _currentQuery = _currentQuery.copyWith(
          page: (_currentQuery.page ?? initialPage) + 1);
    } else {
      _currentQuery = _currentQuery.copyWith(cursor: result.nextCursor);
    }
  }

  /// Resets the pagination to the first page and reloads.
  Future<void> refresh() async {
    _currentQuery = _currentQuery.copyWith(
      page: type == PaginationType.page ? initialPage : null,
      cursor: null,
    );
    await loadInitial();
  }

  /// Retries the last failed request.
  Future<void> retry() async {
    if (value.items.isEmpty) {
      await loadInitial();
    } else {
      await fetchMore();
    }
  }

  /// Updates the search query and refreshes the list.
  void search(String query) {
    _currentQuery = _currentQuery.copyWith(searchQuery: query);
    refresh();
  }

  /// Updates the filters and refreshes the list.
  void applyFilter(Map<String, dynamic> filters) {
    _currentQuery = _currentQuery.copyWith(filters: filters);
    refresh();
  }
}
