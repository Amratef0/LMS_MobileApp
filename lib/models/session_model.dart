import 'paginated.dart';
import 'user_model.dart';

class NamedRef {
  NamedRef({required this.id, required this.name});
  final int id;
  final String name;

  factory NamedRef.fromJson(Map<String, dynamic> json) =>
      NamedRef(id: asIntOr(json['id']), name: asStr(json['name']));
}

/// One row from GET /sessions.
class SessionListItem {
  SessionListItem({
    required this.id,
    required this.name,
    required this.trainer,
    required this.sessionDate,
    required this.type,
    required this.topic,
    required this.status,
    required this.group,
    this.recordLink,
    this.location,
  });

  final int id;
  final String name;
  final NamedRef trainer;
  final DateTime? sessionDate;
  final String type;
  final String topic;
  final String status;
  final GroupRef group;
  final String? recordLink;
  final String? location;

  factory SessionListItem.fromJson(Map<String, dynamic> json) => SessionListItem(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        trainer: NamedRef.fromJson(Map<String, dynamic>.from(json['trainer'] as Map? ?? {})),
        sessionDate: asDate(json['sessionDate']),
        type: asStr(json['type']),
        topic: asStr(json['topic']),
        status: asStr(json['status']),
        group: GroupRef.fromJson(Map<String, dynamic>.from(json['group'] as Map? ?? {})),
        recordLink: json['recordLink'] as String?,
        location: json['location'] as String?,
      );
}

class SessionAttachmentModel {
  SessionAttachmentModel({
    required this.id,
    required this.title,
    this.fileUrl,
    this.link,
    required this.attachmentType,
    required this.uploadedBy,
    this.createdAt,
  });

  final int id;
  final String title;
  final String? fileUrl;
  final String? link;
  final String attachmentType; // link | pdf
  final String uploadedBy;
  final DateTime? createdAt;

  factory SessionAttachmentModel.fromJson(Map<String, dynamic> json) => SessionAttachmentModel(
        id: asIntOr(json['id']),
        title: asStr(json['title']),
        fileUrl: json['fileUrl'] as String?,
        link: json['link'] as String?,
        attachmentType: asStr(json['attachmentType'], 'link'),
        uploadedBy: asStr(json['uploadedBy']),
        createdAt: asDate(json['createdAt']),
      );
}

class SessionQuizSummary {
  SessionQuizSummary({
    required this.id,
    required this.title,
    required this.type,
    this.dueDate,
    required this.submissionsCount,
    this.myScore,
    this.myTotalPoints,
  });

  final int id;
  final String title;
  final String type;
  final DateTime? dueDate;
  final int submissionsCount;
  final int? myScore;
  final int? myTotalPoints;

  bool get iSubmitted => myScore != null;

  factory SessionQuizSummary.fromJson(Map<String, dynamic> json) {
    final my = json['mySubmission'] as Map?;
    return SessionQuizSummary(
      id: asIntOr(json['id']),
      title: asStr(json['title']),
      type: asStr(json['type']),
      dueDate: asDate(json['dueDate']),
      submissionsCount: asIntOr(json['submissionsCount']),
      myScore: my == null ? null : asInt(my['score']),
      myTotalPoints: my == null ? null : asInt(my['totalPoints']),
    );
  }
}

class SessionAssignmentSummary {
  SessionAssignmentSummary({
    required this.id,
    required this.title,
    this.dueDate,
    this.description,
    required this.isGraded,
    required this.submissionsCount,
    required this.mySubmitted,
    this.myGrade,
    this.myFeedback,
  });

  final int id;
  final String title;
  final DateTime? dueDate;
  final String? description;
  final bool isGraded;
  final int submissionsCount;
  final bool mySubmitted;
  final int? myGrade;
  final String? myFeedback;

  factory SessionAssignmentSummary.fromJson(Map<String, dynamic> json) {
    final my = json['mySubmission'] as Map?;
    return SessionAssignmentSummary(
      id: asIntOr(json['id']),
      title: asStr(json['title']),
      dueDate: asDate(json['dueDate']),
      description: json['description'] as String?,
      isGraded: asBool(json['isGraded'], true),
      submissionsCount: asIntOr(json['submissionsCount']),
      mySubmitted: asBool(json['mySubmitted']),
      myGrade: my == null ? null : asInt(my['grade']),
      myFeedback: my == null ? null : my['gradeFeedback'] as String?,
    );
  }
}

/// GET /sessions/{id}
class SessionDetail {
  SessionDetail({
    required this.id,
    required this.name,
    this.sessionDate,
    required this.type,
    required this.topic,
    required this.status,
    this.recordLink,
    this.location,
    required this.trainer,
    required this.group,
    required this.attendanceTaken,
    required this.attendanceTotal,
    required this.attendanceJoined,
    this.myJoined,
    required this.attachments,
    required this.quizzes,
    required this.assignments,
  });

  final int id;
  final String name;
  final DateTime? sessionDate;
  final String type;
  final String topic;
  final String status;
  final String? recordLink;
  final String? location;
  final NamedRef trainer;
  final GroupRef group;
  final bool attendanceTaken;
  final int attendanceTotal;
  final int attendanceJoined;
  final bool? myJoined;
  final List<SessionAttachmentModel> attachments;
  final List<SessionQuizSummary> quizzes;
  final List<SessionAssignmentSummary> assignments;

  bool get isPending => status == 'pending';
  bool get isRunning => status == 'running';
  bool get isFinished => status == 'finished';
  bool get isCancelled => status == 'cancelled';

  factory SessionDetail.fromJson(Map<String, dynamic> json) {
    final attendance = json['attendance'] as Map? ?? {};
    final myAttendance = json['myAttendance'] as Map?;
    return SessionDetail(
      id: asIntOr(json['id']),
      name: asStr(json['name']),
      sessionDate: asDate(json['sessionDate']),
      type: asStr(json['type']),
      topic: asStr(json['topic']),
      status: asStr(json['status']),
      recordLink: json['recordLink'] as String?,
      location: json['location'] as String?,
      trainer: NamedRef.fromJson(Map<String, dynamic>.from(json['trainer'] as Map? ?? {})),
      group: GroupRef.fromJson(Map<String, dynamic>.from(json['group'] as Map? ?? {})),
      attendanceTaken: json['attendanceStatus'] == 'taken',
      attendanceTotal: asIntOr(attendance['total']),
      attendanceJoined: asIntOr(attendance['joined']),
      myJoined: myAttendance == null ? null : asBool(myAttendance['joined']),
      attachments: ((json['attachments'] as List?) ?? [])
          .map((e) => SessionAttachmentModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      quizzes: ((json['quizzes'] as List?) ?? [])
          .map((e) => SessionQuizSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      assignments: ((json['assignments'] as List?) ?? [])
          .map((e) => SessionAssignmentSummary.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class AttendanceRow {
  AttendanceRow({
    required this.studentId,
    required this.studentName,
    this.studentCode,
    required this.joined,
  });

  final int studentId;
  final String studentName;
  final String? studentCode;
  bool joined;

  factory AttendanceRow.fromJson(Map<String, dynamic> json) => AttendanceRow(
        studentId: asIntOr(json['studentId']),
        studentName: asStr(json['studentName']),
        studentCode: json['studentCode'] as String?,
        joined: asBool(json['joined']),
      );
}
