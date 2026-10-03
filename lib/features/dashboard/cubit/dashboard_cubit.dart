import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState());
  final DashboardRepository _repository;

  Future<void> load({required bool isStudent}) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      if (isStudent) {
        final data = await _repository.fetchStudent();
        emit(state.copyWith(status: DashboardStatus.studentReady, student: data));
      } else {
        final data = await _repository.fetchStaff();
        emit(state.copyWith(status: DashboardStatus.staffReady, staff: data));
      }
    } on ApiException catch (e) {
      emit(state.copyWith(status: DashboardStatus.error, errorMessage: e.message));
    }
  }
}
