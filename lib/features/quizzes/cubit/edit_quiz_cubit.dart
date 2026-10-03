import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/session_model.dart';
import '../../sessions/sessions_repository.dart';
import '../quizzes_repository.dart';

enum EditQuizStatus { loadingOptions, ready, submitting, done, error }

class EditQuizState extends Equatable {
  const EditQuizState({
    this.status = EditQuizStatus.loadingOptions,
    this.sessions = const [],
    this.errorMessage,
  });

  final EditQuizStatus status;
  final List<SessionListItem> sessions;
  final String? errorMessage;

  EditQuizState copyWith({EditQuizStatus? status, List<SessionListItem>? sessions, String? errorMessage}) =>
      EditQuizState(status: status ?? this.status, sessions: sessions ?? this.sessions, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}

class EditQuizCubit extends Cubit<EditQuizState> {
  EditQuizCubit({
    required QuizzesRepository quizzesRepository,
    required SessionsRepository sessionsRepository,
  })  : _quizzesRepository = quizzesRepository,
        _sessionsRepository = sessionsRepository,
        super(const EditQuizState());

  final QuizzesRepository _quizzesRepository;
  final SessionsRepository _sessionsRepository;

  Future<void> loadOptions() async {
    emit(state.copyWith(status: EditQuizStatus.loadingOptions));
    try {
      final sessions = await _sessionsRepository.list(pageSize: 200);
      emit(state.copyWith(status: EditQuizStatus.ready, sessions: sessions.items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: EditQuizStatus.error, errorMessage: e.message));
    }
  }

  Future<void> submit({
    required int quizId,
    required String title,
    required String type,
    required bool isGraded,
    DateTime? dueDate,
    int? sessionId,
    required List<Map<String, dynamic>> questions,
  }) async {
    emit(state.copyWith(status: EditQuizStatus.submitting, errorMessage: null));
    try {
      await _quizzesRepository.update(
        quizId: quizId,
        title: title,
        type: type,
        isGraded: isGraded,
        dueDate: dueDate,
        sessionId: sessionId,
        questions: questions,
      );
      emit(state.copyWith(status: EditQuizStatus.done));
    } on ApiException catch (e) {
      emit(state.copyWith(status: EditQuizStatus.error, errorMessage: e.message));
    }
  }
}
