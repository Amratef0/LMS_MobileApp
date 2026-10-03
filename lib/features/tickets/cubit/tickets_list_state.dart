import 'package:equatable/equatable.dart';
import '../../../models/ticket_model.dart';

enum ListStatus { initial, loading, ready, error }

class TicketsListState extends Equatable {
  const TicketsListState({
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
  final List<TicketListItem> items;
  final int total, page, pageSize;
  final String? search;
  final String? statusFilter;
  final String? errorMessage;

  TicketsListState copyWith({
    ListStatus? status,
    List<TicketListItem>? items,
    int? total,
    int? page,
    String? search,
    String? statusFilter,
    String? errorMessage,
  }) =>
      TicketsListState(
        status: status ?? this.status,
        items: items ?? this.items,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize,
        search: search ?? this.search,
        statusFilter: statusFilter ?? this.statusFilter,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, items, total, page, pageSize, search, statusFilter, errorMessage];
}
