import 'package:equatable/equatable.dart';
import '../../../models/assignment_model.dart';
import '../../../models/paginated.dart';
import '../../../models/session_model.dart';

enum DetailStatus { initial, loading, ready, error }
enum SubmitStatus { idle, uploading, submitting, done, error }

class AssignmentDetailData {
  AssignmentDetailData.fromJson(Map<String, dynamic> json)
      : id = asIntOr(json['id']),
        title = asStr(json['title']),
        description = json['description'] as String?,
        dueDate = asDate(json['dueDate']),
        isGraded = asBool(json['isGraded'], true),
        session = json['session'] == null
            ? null
            : NamedRef.fromJson(Map<String, dynamic>.from(json['session'] as Map)),
        mySubmission = json['mySubmission'] == null
            ? null
            : AssignmentSubmissionRow.fromJson(Map<String, dynamic>.from({
                ...Map<String, dynamic>.from(json['mySubmission'] as Map),
              })),
        submissions = ((json['submissions'] as List?) ?? [])
            .map((e) => AssignmentSubmissionRow.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        missedStudents = ((json['missedStudents'] as List?) ?? [])
            .map((e) => MissedStudentRow.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

  final int id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isGraded;
  final NamedRef? session;
  final AssignmentSubmissionRow? mySubmission;
  final List<AssignmentSubmissionRow> submissions;
  final List<MissedStudentRow> missedStudents;

  bool get isPastDue => dueDate != null && dueDate!.toLocal().isBefore(DateTime.now());
}

class AssignmentDetailState extends Equatable {
  const AssignmentDetailState({
    this.status = DetailStatus.initial,
    this.data,
    this.submitStatus = SubmitStatus.idle,
    this.errorMessage,
  });

  final DetailStatus status;
  final AssignmentDetailData? data;
  final SubmitStatus submitStatus;
  final String? errorMessage;

  AssignmentDetailState copyWith({
    DetailStatus? status,
    AssignmentDetailData? data,
    SubmitStatus? submitStatus,
    String? errorMessage,
  }) =>
      AssignmentDetailState(
        status: status ?? this.status,
        data: data ?? this.data,
        submitStatus: submitStatus ?? this.submitStatus,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, data, submitStatus, errorMessage];
}
