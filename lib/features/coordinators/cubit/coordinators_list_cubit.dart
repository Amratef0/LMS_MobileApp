import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../coordinators_repository.dart';

enum ListStatus { initial, loading, ready, error }

class CoordinatorsListState extends Equatable {
  const CoordinatorsListState({
    this.status = ListStatus.initial,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.errorMessage,
  });

  final ListStatus status;
  final List<CoordinatorModel> items;
  final int total, page, pageSize;
  final String? search;
  final String? errorMessage;

  CoordinatorsListState copyWith({
    ListStatus? status,
    List<CoordinatorModel>? items,
    int? total,
    int? page,
    String? search,
    String? errorMessage,
  }) =>
      CoordinatorsListState(
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

class CoordinatorsListCubit extends Cubit<CoordinatorsListState> {
  CoordinatorsListCubit(this._repository) : super(const CoordinatorsListState());
  final CoordinatorsRepository _repository;

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
