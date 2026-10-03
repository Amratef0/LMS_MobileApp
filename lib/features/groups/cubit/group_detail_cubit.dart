import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/group_model.dart';
import '../groups_repository.dart';

enum DetailStatus { initial, loading, ready, error }

class GroupDetailState extends Equatable {
  const GroupDetailState({this.status = DetailStatus.initial, this.group, this.errorMessage});
  final DetailStatus status;
  final GroupDetail? group;
  final String? errorMessage;

  GroupDetailState copyWith({DetailStatus? status, GroupDetail? group, String? errorMessage}) =>
      GroupDetailState(status: status ?? this.status, group: group ?? this.group, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, group, errorMessage];
}

class GroupDetailCubit extends Cubit<GroupDetailState> {
  GroupDetailCubit(this._repository, this.groupId) : super(const GroupDetailState());
  final GroupsRepository _repository;
  final int groupId;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading));
    try {
      final group = await _repository.detail(groupId);
      emit(state.copyWith(status: DetailStatus.ready, group: group));
    } on ApiException catch (e) {
      emit(state.copyWith(status: DetailStatus.error, errorMessage: e.message));
    }
  }
}
