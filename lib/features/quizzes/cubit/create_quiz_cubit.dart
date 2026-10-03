import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/session_model.dart';
import '../../sessions/sessions_repository.dart';
import '../quizzes_repository.dart';

enum CreateQuizStatus { loadingOptions, ready, submitting, done, error }

class CreateQuizState extends Equatable {
  const CreateQuizState({
    this.status = CreateQuizStatus.loadingOptions,
    this.sessions = const [],
    this.errorMessage,
  });

  final CreateQuizStatus status;
  final List<SessionListItem> sessions;
  final String? errorMessage;

  CreateQuizState copyWith({
    CreateQuizStatus? status,
    List<SessionListItem>? sessions,
    String? errorMessage,
  }) =>
      CreateQuizState(
        status: status ?? this.status,
        sessions: sessions ?? this.sessions,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}

class CreateQuizCubit extends Cubit<CreateQuizState> {
  CreateQuizCubit({
    required QuizzesRepository quizzesRepository,
    required SessionsRepository sessionsRepository,
  })  : _quizzesRepository = quizzesRepository,
        _sessionsRepository = sessionsRepository,
        super(const CreateQuizState());

  final QuizzesRepository _quizzesRepository;
  final SessionsRepository _sessionsRepository;

  Future<void> loadOptions() async {
    emit(state.copyWith(status: CreateQuizStatus.loadingOptions));
    try {
      final sessions = await _sessionsRepository.list(pageSize: 200);
      emit(state.copyWith(status: CreateQuizStatus.ready, sessions: sessions.items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: CreateQuizStatus.error, errorMessage: e.message));
    }
  }

  Future<void> submit({
    required String title,
    required String type,
    required bool isGraded,
    DateTime? dueDate,
    int? sessionId,
    required List<Map<String, dynamic>> questions,
  }) async {
    emit(state.copyWith(status: CreateQuizStatus.submitting, errorMessage: null));
    try {
      await _quizzesRepository.create(
        title: title,
        type: type,
        isGraded: isGraded,
        dueDate: dueDate,
        sessionId: sessionId,
        questions: questions,
      );
      emit(state.copyWith(status: CreateQuizStatus.done));
    } on ApiException catch (e) {
      emit(state.copyWith(status: CreateQuizStatus.error, errorMessage: e.message));
    }
  }
}
