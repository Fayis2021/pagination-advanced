import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/pagination_query.dart';
import '../models/pagination_result.dart';
import '../models/pagination_state.dart';
import '../controllers/pagination_controller.dart'; // for PaginationType and FetchData
import 'pagination_event.dart';

class PaginationBloc<T> extends Bloc<PaginationEvent, PaginationState<T>> {
  final FetchData<T> fetch;
  final PaginationType type;
  final int initialPage;

  late PaginationQuery _currentQuery;

  PaginationBloc({
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

    on<PaginationLoadInitial>(_onLoadInitial);
    on<PaginationFetchMore>(_onFetchMore);
    on<PaginationRefresh>(_onRefresh);
    on<PaginationRetry>(_onRetry);
    on<PaginationSearch>(_onSearch);
    on<PaginationApplyFilter>(_onApplyFilter);

    if (initialData == null) {
      add(PaginationLoadInitial());
    }
  }

  Future<void> _onLoadInitial(
      PaginationLoadInitial event, Emitter<PaginationState<T>> emit) async {
    emit(state.copyWith(status: PaginationStatus.initialLoading, error: null));
    try {
      final result = await fetch(_currentQuery);
      _updateQueryFromResult(result);

      emit(state.copyWith(
        status: PaginationStatus.loaded,
        items: result.items,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(status: PaginationStatus.error, error: e));
    }
  }

  Future<void> _onFetchMore(
      PaginationFetchMore event, Emitter<PaginationState<T>> emit) async {
    if (state.status == PaginationStatus.loadingMore ||
        state.status == PaginationStatus.initialLoading ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(status: PaginationStatus.loadingMore));

    try {
      final result = await fetch(_currentQuery);
      _updateQueryFromResult(result);

      emit(state.copyWith(
        status: PaginationStatus.loaded,
        items: [...state.items, ...result.items],
        hasMore: result.hasMore,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: PaginationStatus.error, error: e));
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

  Future<void> _onRefresh(
      PaginationRefresh event, Emitter<PaginationState<T>> emit) async {
    _currentQuery = _currentQuery.copyWith(
      page: type == PaginationType.page ? initialPage : null,
      cursor: null,
    );
    await _onLoadInitial(PaginationLoadInitial(), emit);
  }

  Future<void> _onRetry(
      PaginationRetry event, Emitter<PaginationState<T>> emit) async {
    if (state.items.isEmpty) {
      await _onLoadInitial(PaginationLoadInitial(), emit);
    } else {
      await _onFetchMore(PaginationFetchMore(), emit);
    }
  }

  void _onSearch(PaginationSearch event, Emitter<PaginationState<T>> emit) {
    _currentQuery = _currentQuery.copyWith(searchQuery: event.query);
    add(PaginationRefresh());
  }

  void _onApplyFilter(
      PaginationApplyFilter event, Emitter<PaginationState<T>> emit) {
    _currentQuery = _currentQuery.copyWith(filters: event.filters);
    add(PaginationRefresh());
  }
}
