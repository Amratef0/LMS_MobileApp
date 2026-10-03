import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/group_model.dart';
import '../../groups/groups_repository.dart';
import '../reports_repository.dart';

enum ReportsStatus { loadingGroups, ready, downloading, error }

class ReportsState extends Equatable {
  const ReportsState({
    this.status = ReportsStatus.loadingGroups,
    this.groups = const [],
    this.errorMessage,
  });

  final ReportsStatus status;
  final List<GroupListItem> groups;
  final String? errorMessage;

  ReportsState copyWith({ReportsStatus? status, List<GroupListItem>? groups, String? errorMessage}) =>
      ReportsState(
        status: status ?? this.status,
        groups: groups ?? this.groups,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, groups, errorMessage];
}

/// Backs the staff Reports screen: loads the group picker options, then
/// downloads + shares whichever .xlsx/.pdf report the person taps.
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({required ReportsRepository reportsRepository, required GroupsRepository groupsRepository})
      : _reportsRepository = reportsRepository,
        _groupsRepository = groupsRepository,
        super(const ReportsState());

  final ReportsRepository _reportsRepository;
  final GroupsRepository _groupsRepository;

  Future<void> loadGroups() async {
    emit(state.copyWith(status: ReportsStatus.loadingGroups));
    try {
      final groups = await _groupsRepository.list(pageSize: 200);
      emit(state.copyWith(status: ReportsStatus.ready, groups: groups.items));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ReportsStatus.error, errorMessage: e.message));
    }
  }

  Future<void> download(Future<void> Function() action) async {
    emit(state.copyWith(status: ReportsStatus.downloading, errorMessage: null));
    try {
      await action();
      emit(state.copyWith(status: ReportsStatus.ready));
    } on ApiException catch (e) {
      emit(state.copyWith(status: ReportsStatus.ready, errorMessage: e.message));
    }
  }

  Future<void> attendance(int groupId, String name) =>
      download(() => _reportsRepository.attendanceReport(groupId, name));
  Future<void> grades(int groupId, String name) => download(() => _reportsRepository.gradesReport(groupId, name));
  Future<void> summary(int groupId, String name) =>
      download(() => _reportsRepository.groupSummaryReport(groupId, name));
  Future<void> myProgress() => download(() => _reportsRepository.studentProgressReport());
}
