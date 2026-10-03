import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../sessions_repository.dart';
import 'session_detail_state.dart';
import '../../../models/session_model.dart';

class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit(this._repository, this.sessionId) : super(const SessionDetailState());
  final SessionsRepository _repository;
  final int sessionId;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading));
    try {
      final session = await _repository.detail(sessionId);
      emit(state.copyWith(status: DetailStatus.ready, session: session));
    } on ApiException catch (e) {
      emit(state.copyWith(status: DetailStatus.error, errorMessage: e.message));
    }
  }

  Future<void> loadAttendance() async {
    emit(state.copyWith(attendanceLoading: true));
    try {
      final rows = await _repository.getAttendance(sessionId);
      emit(state.copyWith(attendance: rows, attendanceLoading: false));
    } on ApiException catch (e) {
      emit(state.copyWith(attendanceLoading: false, errorMessage: e.message));
    }
  }

  void toggleAttendance(int studentId, bool joined) {
    final updated = state.attendance
        .map((r) => r.studentId == studentId ? AttendanceRow(
              studentId: r.studentId,
              studentName: r.studentName,
              studentCode: r.studentCode,
              joined: joined,
            ) : r)
        .toList();
    emit(state.copyWith(attendance: updated));
  }

  Future<bool> saveAttendance() async {
    emit(state.copyWith(actionInProgress: true));
    try {
      await _repository.saveAttendance(sessionId, state.attendance);
      emit(state.copyWith(actionInProgress: false));
      await load();
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(actionInProgress: false, errorMessage: e.message));
      return false;
    }
  }

  Future<bool> run() => _runAction(() => _repository.run(sessionId));
  Future<bool> finish() => _runAction(() => _repository.finish(sessionId));
  Future<bool> cancel() => _runAction(() => _repository.cancel(sessionId));

  Future<bool> _runAction(Future<void> Function() action) async {
    emit(state.copyWith(actionInProgress: true, errorMessage: null));
    try {
      await action();
      emit(state.copyWith(actionInProgress: false));
      await load();
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(actionInProgress: false, errorMessage: e.message));
      return false;
    }
  }
}
