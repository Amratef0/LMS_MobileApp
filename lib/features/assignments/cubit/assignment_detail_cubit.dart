import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../assignments_repository.dart';
import 'assignment_detail_state.dart';

class AssignmentDetailCubit extends Cubit<AssignmentDetailState> {
  AssignmentDetailCubit(this._repository, this.assignmentId) : super(const AssignmentDetailState());
  final AssignmentsRepository _repository;
  final int assignmentId;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading));
    try {
      final json = await _repository.detailRaw(assignmentId);
      emit(state.copyWith(status: DetailStatus.ready, data: AssignmentDetailData.fromJson(json)));
    } on ApiException catch (e) {
      emit(state.copyWith(status: DetailStatus.error, errorMessage: e.message));
    }
  }

  Future<void> submitFile(String filePath, String fileName) async {
    emit(state.copyWith(submitStatus: SubmitStatus.uploading, errorMessage: null));
    try {
      final url = await _repository.uploadFile(filePath, fileName);
      emit(state.copyWith(submitStatus: SubmitStatus.submitting));
      await _repository.submitFile(assignmentId, url);
      emit(state.copyWith(submitStatus: SubmitStatus.done));
      await load();
    } on ApiException catch (e) {
      emit(state.copyWith(submitStatus: SubmitStatus.error, errorMessage: e.message));
    }
  }

  Future<void> submitLink(String link) async {
    emit(state.copyWith(submitStatus: SubmitStatus.submitting, errorMessage: null));
    try {
      await _repository.submitLink(assignmentId, link);
      emit(state.copyWith(submitStatus: SubmitStatus.done));
      await load();
    } on ApiException catch (e) {
      emit(state.copyWith(submitStatus: SubmitStatus.error, errorMessage: e.message));
    }
  }

  Future<bool> grade(int submissionId, int grade, String? feedback) async {
    try {
      await _repository.grade(assignmentId, submissionId, grade: grade, feedback: feedback);
      await load();
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      return false;
    }
  }
}
