import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/instructor_model.dart';
import '../../instructors/instructors_repository.dart';
import '../sessions_repository.dart';

enum EditSessionStatus { loadingOptions, ready, submitting, done, error }

class EditSessionState extends Equatable {
  const EditSessionState({
    this.status = EditSessionStatus.loadingOptions,
    this.instructors = const [],
    this.errorMessage,
  });

  final EditSessionStatus status;
  final List<InstructorModel> instructors;
  final String? errorMessage;

  EditSessionState copyWith({
    EditSessionStatus? status,
    List<InstructorModel>? instructors,
    String? errorMessage,
  }) =>
      EditSessionState(
        status: status ?? this.status,
        instructors: instructors ?? this.instructors,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, instructors, errorMessage];
}

class EditSessionCubit extends Cubit<EditSessionState> {
  EditSessionCubit({
    required SessionsRepository sessionsRepository,
    required InstructorsRepository instructorsRepository,
  })  : _sessionsRepository = sessionsRepository,
        _instructorsRepository = instructorsRepository,
        super(const EditSessionState());

  final SessionsRepository _sessionsRepository;
  final InstructorsRepository _instructorsRepository;

  Future<void> loadOptions() async {
    emit(state.copyWith(status: EditSessionStatus.loadingOptions));
    try {
      final instructors = await _instructorsRepository.list(pageSize: 200);
      emit(state.copyWith(status: EditSessionStatus.ready, instructors: instructors.items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: EditSessionStatus.error, errorMessage: e.message));
    }
  }

  Future<void> submit({
    required int sessionId,
    required String name,
    required int trainerId,
    required DateTime sessionDate,
    required String type,
    required String topic,
    String? location,
  }) async {
    emit(state.copyWith(status: EditSessionStatus.submitting, errorMessage: null));
    try {
      await _sessionsRepository.update(
        sessionId,
        name: name,
        trainerId: trainerId,
        sessionDate: sessionDate,
        type: type,
        topic: topic,
        location: location,
      );
      emit(state.copyWith(status: EditSessionStatus.done));
    } on ApiException catch (e) {
      emit(state.copyWith(status: EditSessionStatus.error, errorMessage: e.message));
    }
  }
}
