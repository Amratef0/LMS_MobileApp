import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/auth_repository.dart';

enum ChangePasswordStatus { idle, submitting, done, error }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({this.status = ChangePasswordStatus.idle, this.errorMessage});
  final ChangePasswordStatus status;
  final String? errorMessage;

  ChangePasswordState copyWith({ChangePasswordStatus? status, String? errorMessage}) =>
      ChangePasswordState(status: status ?? this.status, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._repository) : super(const ChangePasswordState());
  final AuthRepository _repository;

  Future<void> submit(String current, String next) async {
    emit(state.copyWith(status: ChangePasswordStatus.submitting, errorMessage: null));
    try {
      await _repository.changePassword(currentPassword: current, newPassword: next);
      emit(state.copyWith(status: ChangePasswordStatus.done));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ChangePasswordStatus.error, errorMessage: e.message));
    }
  }
}
