import 'package:flutter/foundation.dart';
import '../models/pagination_query.dart';
import '../models/pagination_result.dart';
import '../models/pagination_state.dart';

enum PaginationType { page, cursor }

typedef FetchData<T> = Future<PaginationResult<T>> Function(PaginationQuery query);

class PaginationController<T> extends ValueNotifier<PaginationState<T>> {
  final FetchData<T> fetch;
  final PaginationType type;
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

  Future<void> refresh() async {
    _currentQuery = _currentQuery.copyWith(
      page: type == PaginationType.page ? initialPage : null,
      cursor: null,
    );
    await loadInitial();
  }

  Future<void> retry() async {
    if (value.items.isEmpty) {
      await loadInitial();
    } else {
      await fetchMore();
    }
  }

  void search(String query) {
    _currentQuery = _currentQuery.copyWith(searchQuery: query);
    refresh();
  }

  void applyFilter(Map<String, dynamic> filters) {
    _currentQuery = _currentQuery.copyWith(filters: filters);
    refresh();
  }
}
