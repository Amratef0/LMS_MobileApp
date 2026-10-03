import 'paginated.dart';
import 'session_model.dart';

/// One row from GET /assignments.
class AssignmentListItem {
  AssignmentListItem({
    required this.id,
    required this.title,
    required this.isGraded,
    this.createdAt,
    this.dueDate,
    this.description,
    this.session,
    required this.submissionsCount,
  });

  final int id;
  final String title;
  final bool isGraded;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final String? description;
  final NamedRef? session;
  final int submissionsCount;

  factory AssignmentListItem.fromJson(Map<String, dynamic> json) => AssignmentListItem(
        id: asIntOr(json['id']),
        title: asStr(json['title']),
        isGraded: asBool(json['isGraded'], true),
        createdAt: asDate(json['createdAt']),
        dueDate: asDate(json['dueDate']),
        description: json['description'] as String?,
        session: json['session'] == null
            ? null
            : NamedRef.fromJson(Map<String, dynamic>.from(json['session'] as Map)),
        submissionsCount: asIntOr(json['submissionsCount']),
      );
}

class AssignmentSubmissionRow {
  AssignmentSubmissionRow({
    required this.id,
    this.studentId,
    this.studentName,
    this.studentCode,
    this.fileUrl,
    this.link,
    required this.submissionType,
    this.grade,
    this.gradeFeedback,
    this.submittedAt,
  });

  final int id;
  final int? studentId;
  final String? studentName;
  final String? studentCode;
  final String? fileUrl;
  final String? link;
  final String submissionType;
  final int? grade;
  final String? gradeFeedback;
  final DateTime? submittedAt;

  factory AssignmentSubmissionRow.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map?;
    return AssignmentSubmissionRow(
      id: asIntOr(json['id']),
      studentId: student == null ? null : asInt(student['id']),
      studentName: student == null ? null : asStr(student['name']),
      studentCode: student == null ? null : student['studentCode'] as String?,
      fileUrl: json['fileUrl'] as String?,
      link: json['link'] as String?,
      submissionType: asStr(json['submissionType'], 'file'),
      grade: asInt(json['grade']),
      gradeFeedback: json['gradeFeedback'] as String?,
      submittedAt: asDate(json['submittedAt']),
    );
  }
}

class MissedStudentRow {
  MissedStudentRow({required this.id, required this.name, this.studentCode});
  final int id;
  final String name;
  final String? studentCode;

  factory MissedStudentRow.fromJson(Map<String, dynamic> json) => MissedStudentRow(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        studentCode: json['studentCode'] as String?,
      );
}
