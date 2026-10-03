import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/instructor_model.dart';
import '../../../models/group_model.dart';
import '../../instructors/instructors_repository.dart';
import '../../groups/groups_repository.dart';
import '../sessions_repository.dart';

enum CreateSessionStatus { loadingOptions, ready, submitting, done, error }

class CreateSessionState extends Equatable {
  const CreateSessionState({
    this.status = CreateSessionStatus.loadingOptions,
    this.instructors = const [],
    this.groups = const [],
    this.errorMessage,
  });

  final CreateSessionStatus status;
  final List<InstructorModel> instructors;
  final List<GroupListItem> groups;
  final String? errorMessage;

  CreateSessionState copyWith({
    CreateSessionStatus? status,
    List<InstructorModel>? instructors,
    List<GroupListItem>? groups,
    String? errorMessage,
  }) =>
      CreateSessionState(
        status: status ?? this.status,
        instructors: instructors ?? this.instructors,
        groups: groups ?? this.groups,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, instructors, groups, errorMessage];
}

/// Backs the "New session" form: loads the instructor/group dropdown
/// options, then submits POST /sessions (SessionsController.CreateSession).
class CreateSessionCubit extends Cubit<CreateSessionState> {
  CreateSessionCubit({
    required SessionsRepository sessionsRepository,
    required InstructorsRepository instructorsRepository,
    required GroupsRepository groupsRepository,
  })  : _sessionsRepository = sessionsRepository,
        _instructorsRepository = instructorsRepository,
        _groupsRepository = groupsRepository,
        super(const CreateSessionState());

  final SessionsRepository _sessionsRepository;
  final InstructorsRepository _instructorsRepository;
  final GroupsRepository _groupsRepository;

  Future<void> loadOptions() async {
    emit(state.copyWith(status: CreateSessionStatus.loadingOptions));
    try {
      final instructors = await _instructorsRepository.list(pageSize: 200);
      final groups = await _groupsRepository.list(pageSize: 200);
      emit(state.copyWith(
        status: CreateSessionStatus.ready,
        instructors: instructors.items,
        groups: groups.items,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: CreateSessionStatus.error, errorMessage: e.message));
    }
  }

  Future<void> submit({
    required String name,
    required int trainerId,
    required int groupId,
    required DateTime sessionDate,
    required String type,
    required String topic,
    String? location,
    String? recordLink,
  }) async {
    emit(state.copyWith(status: CreateSessionStatus.submitting, errorMessage: null));
    try {
      await _sessionsRepository.create(
        name: name,
        trainerId: trainerId,
        groupId: groupId,
        sessionDate: sessionDate,
        type: type,
        topic: topic,
        location: location,
        recordLink: recordLink,
      );
      emit(state.copyWith(status: CreateSessionStatus.done));
    } on ApiException catch (e) {
      emit(state.copyWith(status: CreateSessionStatus.error, errorMessage: e.message));
    }
  }
}
