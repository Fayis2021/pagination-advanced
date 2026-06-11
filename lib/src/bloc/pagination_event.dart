import 'package:equatable/equatable.dart';

abstract class PaginationEvent extends Equatable {
  const PaginationEvent();

  @override
  List<Object?> get props => [];
}

class PaginationLoadInitial extends PaginationEvent {}

class PaginationFetchMore extends PaginationEvent {}

class PaginationRefresh extends PaginationEvent {}

class PaginationRetry extends PaginationEvent {}

class PaginationSearch extends PaginationEvent {
  final String query;
  const PaginationSearch(this.query);

  @override
  List<Object?> get props => [query];
}

class PaginationApplyFilter extends PaginationEvent {
  final Map<String, dynamic> filters;
  const PaginationApplyFilter(this.filters);

  @override
  List<Object?> get props => [filters];
}
