import 'package:equatable/equatable.dart';
import '../../../models/assignment_model.dart';

enum ListStatus { initial, loading, ready, error }

class AssignmentsListState extends Equatable {
  const AssignmentsListState({
    this.status = ListStatus.initial,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.errorMessage,
  });

  final ListStatus status;
  final List<AssignmentListItem> items;
  final int total, page, pageSize;
  final String? search;
  final String? errorMessage;

  AssignmentsListState copyWith({
    ListStatus? status,
    List<AssignmentListItem>? items,
    int? total,
    int? page,
    String? search,
    String? errorMessage,
  }) =>
      AssignmentsListState(
        status: status ?? this.status,
        items: items ?? this.items,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize,
        search: search ?? this.search,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, items, total, page, pageSize, search, errorMessage];
}
