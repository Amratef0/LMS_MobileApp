import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../quizzes_repository.dart';
import 'quiz_detail_state.dart';

class QuizDetailCubit extends Cubit<QuizDetailState> {
  QuizDetailCubit(this._repository, this.quizId) : super(const QuizDetailState());
  final QuizzesRepository _repository;
  final int quizId;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading));
    try {
      final quiz = await _repository.detail(quizId);
      emit(state.copyWith(status: DetailStatus.ready, quiz: quiz));
    } on ApiException catch (e) {
      emit(state.copyWith(status: DetailStatus.error, errorMessage: e.message));
    }
  }

  void answer(int questionId, String value) {
    final updated = Map<int, String>.from(state.answers)..[questionId] = value;
    emit(state.copyWith(answers: updated));
  }

  Future<void> submit() async {
    emit(state.copyWith(submitStatus: SubmitStatus.submitting, errorMessage: null));
    try {
      final res = await _repository.submit(quizId, state.answers);
      emit(state.copyWith(
        submitStatus: SubmitStatus.done,
        score: (res['score'] as num?)?.toInt(),
        totalPoints: (res['totalPoints'] as num?)?.toInt(),
      ));
      load();
    } on ApiException catch (e) {
      emit(state.copyWith(submitStatus: SubmitStatus.error, errorMessage: e.message));
    }
  }
}
