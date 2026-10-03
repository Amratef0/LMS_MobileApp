import 'package:equatable/equatable.dart';
import '../../../models/session_model.dart';

enum DetailStatus { initial, loading, ready, error }

class SessionDetailState extends Equatable {
  const SessionDetailState({
    this.status = DetailStatus.initial,
    this.session,
    this.attendance = const [],
    this.attendanceLoading = false,
    this.actionInProgress = false,
    this.errorMessage,
  });

  final DetailStatus status;
  final SessionDetail? session;
  final List<AttendanceRow> attendance;
  final bool attendanceLoading;
  final bool actionInProgress;
  final String? errorMessage;

  SessionDetailState copyWith({
    DetailStatus? status,
    SessionDetail? session,
    List<AttendanceRow>? attendance,
    bool? attendanceLoading,
    bool? actionInProgress,
    String? errorMessage,
  }) =>
      SessionDetailState(
        status: status ?? this.status,
        session: session ?? this.session,
        attendance: attendance ?? this.attendance,
        attendanceLoading: attendanceLoading ?? this.attendanceLoading,
        actionInProgress: actionInProgress ?? this.actionInProgress,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, session, attendance, attendanceLoading, actionInProgress, errorMessage];
}
