import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../students_repository.dart';
import 'students_list_state.dart';

class StudentsListCubit extends Cubit<StudentsListState> {
  StudentsListCubit(this._repository) : super(const StudentsListState());
  final StudentsRepository _repository;

  Future<void> load({int page = 1}) async {
    emit(state.copyWith(status: ListStatus.loading, page: page));
    try {
      final result = await _repository.list(search: state.search, page: page, pageSize: state.pageSize);
      emit(state.copyWith(status: ListStatus.ready, items: result.items, total: result.total, page: result.page));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ListStatus.error, errorMessage: e.message));
    }
  }

  void search(String value) {
    emit(state.copyWith(search: value.isEmpty ? null : value));
    load(page: 1);
  }
}
