import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/session_model.dart';
import '../../sessions/sessions_repository.dart';
import '../assignments_repository.dart';

enum CreateAssignmentStatus { loadingOptions, ready, submitting, done, error }

class CreateAssignmentState extends Equatable {
  const CreateAssignmentState({
    this.status = CreateAssignmentStatus.loadingOptions,
    this.sessions = const [],
    this.errorMessage,
  });

  final CreateAssignmentStatus status;
  final List<SessionListItem> sessions;
  final String? errorMessage;

  CreateAssignmentState copyWith({
    CreateAssignmentStatus? status,
    List<SessionListItem>? sessions,
    String? errorMessage,
  }) =>
      CreateAssignmentState(
        status: status ?? this.status,
        sessions: sessions ?? this.sessions,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}

class CreateAssignmentCubit extends Cubit<CreateAssignmentState> {
  CreateAssignmentCubit({
    required AssignmentsRepository assignmentsRepository,
    required SessionsRepository sessionsRepository,
  })  : _assignmentsRepository = assignmentsRepository,
        _sessionsRepository = sessionsRepository,
        super(const CreateAssignmentState());

  final AssignmentsRepository _assignmentsRepository;
  final SessionsRepository _sessionsRepository;

  Future<void> loadOptions() async {
    emit(state.copyWith(status: CreateAssignmentStatus.loadingOptions));
    try {
      final sessions = await _sessionsRepository.list(pageSize: 200);
      emit(state.copyWith(status: CreateAssignmentStatus.ready, sessions: sessions.items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: CreateAssignmentStatus.error, errorMessage: e.message));
    }
  }

  Future<void> submit({
    required String title,
    String? description,
    required bool isGraded,
    DateTime? dueDate,
    int? sessionId,
  }) async {
    emit(state.copyWith(status: CreateAssignmentStatus.submitting, errorMessage: null));
    try {
      await _assignmentsRepository.create(
        title: title,
        description: description,
        isGraded: isGraded,
        dueDate: dueDate,
        sessionId: sessionId,
      );
      emit(state.copyWith(status: CreateAssignmentStatus.done));
    } on ApiException catch (e) {
      emit(state.copyWith(status: CreateAssignmentStatus.error, errorMessage: e.message));
    }
  }
}
