import 'package:equatable/equatable.dart';
import '../../../models/dashboard_model.dart';

enum DashboardStatus { initial, loading, studentReady, staffReady, error }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.student,
    this.staff,
    this.errorMessage,
  });

  final DashboardStatus status;
  final StudentDashboard? student;
  final StaffDashboard? staff;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    StudentDashboard? student,
    StaffDashboard? staff,
    String? errorMessage,
  }) =>
      DashboardState(
        status: status ?? this.status,
        student: student ?? this.student,
        staff: staff ?? this.staff,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, student, staff, errorMessage];
}
