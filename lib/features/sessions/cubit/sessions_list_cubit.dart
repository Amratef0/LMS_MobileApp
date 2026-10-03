import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../sessions_repository.dart';
import 'sessions_list_state.dart';

class SessionsListCubit extends Cubit<SessionsListState> {
  SessionsListCubit(this._repository) : super(const SessionsListState());
  final SessionsRepository _repository;

  Future<void> load({int page = 1}) async {
    emit(state.copyWith(status: ListStatus.loading, page: page));
    try {
      final result = await _repository.list(
        search: state.search,
        status: state.statusFilter,
        page: page,
        pageSize: state.pageSize,
      );
      emit(state.copyWith(
        status: ListStatus.ready,
        items: result.items,
        total: result.total,
        page: result.page,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ListStatus.error, errorMessage: e.message));
    }
  }

  void search(String value) {
    emit(state.copyWith(search: value.isEmpty ? null : value));
    load(page: 1);
  }

  void filterByStatus(String? status) {
    emit(SessionsListState(
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
