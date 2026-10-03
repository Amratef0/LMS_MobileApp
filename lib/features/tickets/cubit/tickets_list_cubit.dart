import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../tickets_repository.dart';
import 'tickets_list_state.dart';

class TicketsListCubit extends Cubit<TicketsListState> {
  TicketsListCubit(this._repository, {required this.isStudent}) : super(const TicketsListState());
  final TicketsRepository _repository;
  final bool isStudent;

  Future<void> load({int page = 1}) async {
    emit(state.copyWith(status: ListStatus.loading, page: page));
    try {
      final result = await _repository.list(
        isStudent: isStudent,
        search: state.search,
        status: state.statusFilter,
        page: page,
        pageSize: state.pageSize,
      );
      emit(state.copyWith(status: ListStatus.ready, items: result.items, total: result.total, page: result.page));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ListStatus.error, errorMessage: e.message));
    }
  }

  void search(String value) {
    emit(state.copyWith(search: value.isEmpty ? null : value));
    load(page: 1);
  }

  void filterByStatus(String? status) {
    emit(TicketsListState(
      status: state.status,
      items: state.items,
      total: state.total,
      page: 1,
      pageSize: state.pageSize,
      search: state.search,
      statusFilter: status,
    ));
    load(page: 1);
  }
}
