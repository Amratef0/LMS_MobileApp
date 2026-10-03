import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/session_model.dart';
import '../../sessions/sessions_repository.dart';
import '../assignments_repository.dart';

enum EditAssignmentStatus { loadingOptions, ready, submitting, done, error }

class EditAssignmentState extends Equatable {
  const EditAssignmentState({
    this.status = EditAssignmentStatus.loadingOptions,
    this.sessions = const [],
    this.errorMessage,
  });

  final EditAssignmentStatus status;
  final List<SessionListItem> sessions;
  final String? errorMessage;

  EditAssignmentState copyWith({
    EditAssignmentStatus? status,
    List<SessionListItem>? sessions,
    String? errorMessage,
  }) =>
      EditAssignmentState(
        status: status ?? this.status,
        sessions: sessions ?? this.sessions,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}

class EditAssignmentCubit extends Cubit<EditAssignmentState> {
  EditAssignmentCubit({
    required AssignmentsRepository assignmentsRepository,
    required SessionsRepository sessionsRepository,
  })  : _assignmentsRepository = assignmentsRepository,
        _sessionsRepository = sessionsRepository,
        super(const EditAssignmentState());

  final AssignmentsRepository _assignmentsRepository;
  final SessionsRepository _sessionsRepository;

  Future<void> loadOptions() async {
    emit(state.copyWith(status: EditAssignmentStatus.loadingOptions));
    try {
      final sessions = await _sessionsRepository.list(pageSize: 200);
      emit(state.copyWith(status: EditAssignmentStatus.ready, sessions: sessions.items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: EditAssignmentStatus.error, errorMessage: e.message));
    }
  }

  Future<void> submit({
    required int assignmentId,
    required String title,
    String? description,
    required bool isGraded,
    DateTime? dueDate,
    int? sessionId,
  }) async {
    emit(state.copyWith(status: EditAssignmentStatus.submitting, errorMessage: null));
    try {
      await _assignmentsRepository.update(
        assignmentId: assignmentId,
        title: title,
        description: description,
        isGraded: isGraded,
        dueDate: dueDate,
        sessionId: sessionId,
      );
      emit(state.copyWith(status: EditAssignmentStatus.done));
    } on ApiException catch (e) {
      emit(state.copyWith(status: EditAssignmentStatus.error, errorMessage: e.message));
    }
  }
}
