import 'package:equatable/equatable.dart';
import '../../../models/session_model.dart';

enum ListStatus { initial, loading, ready, error }

class SessionsListState extends Equatable {
  const SessionsListState({
    this.status = ListStatus.initial,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.statusFilter,
    this.errorMessage,
  });

  final ListStatus status;
  final List<SessionListItem> items;
  final int total;
  final int page;
  final int pageSize;
  final String? search;
  final String? statusFilter;
  final String? errorMessage;

  SessionsListState copyWith({
    ListStatus? status,
    List<SessionListItem>? items,
    int? total,
    int? page,
    int? pageSize,
    String? search,
    String? statusFilter,
    String? errorMessage,
  }) =>
      SessionsListState(
        status: status ?? this.status,
        items: items ?? this.items,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        search: search ?? this.search,
        statusFilter: statusFilter ?? this.statusFilter,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, items, total, page, pageSize, search, statusFilter, errorMessage];
}
