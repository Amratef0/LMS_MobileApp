import 'paginated.dart';
import 'session_model.dart';

/// One row from GET /quizzes.
class QuizListItem {
  QuizListItem({
    required this.id,
    required this.title,
    required this.type,
    required this.isGraded,
    this.createdAt,
    this.dueDate,
    this.session,
    required this.submissionsCount,
  });

  final int id;
  final String title;
  final String type;
  final bool isGraded;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final NamedRef? session;
  final int submissionsCount;

  factory QuizListItem.fromJson(Map<String, dynamic> json) => QuizListItem(
        id: asIntOr(json['id']),
        title: asStr(json['title']),
        type: asStr(json['type']),
        isGraded: asBool(json['isGraded'], true),
        createdAt: asDate(json['createdAt']),
        dueDate: asDate(json['dueDate']),
        session: json['session'] == null
            ? null
            : NamedRef.fromJson(Map<String, dynamic>.from(json['session'] as Map)),
        submissionsCount: asIntOr(json['submissionsCount']),
      );
}

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.questionText,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    required this.points,
    required this.order,
    this.correctAnswer,
  });

  final int id;
  final String questionText;
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;
  final int points;
  final int order;
  final String? correctAnswer; // only present for Admin/Coordinator

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: asIntOr(json['id']),
        questionText: asStr(json['questionText']),
        optionA: json['optionA'] as String?,
        optionB: json['optionB'] as String?,
        optionC: json['optionC'] as String?,
        optionD: json['optionD'] as String?,
        points: asIntOr(json['points'], 1),
        order: asIntOr(json['order']),
        correctAnswer: json['correctAnswer'] as String?,
      );
}

class QuizSubmissionRow {
  QuizSubmissionRow({
    required this.id,
    this.studentId,
    this.studentName,
    this.studentCode,
    required this.score,
    required this.totalPoints,
    this.submittedAt,
  });

  final int id;
  final int? studentId;
  final String? studentName;
  final String? studentCode;
  final int score;
  final int totalPoints;
  final DateTime? submittedAt;

  factory QuizSubmissionRow.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map?;
    return QuizSubmissionRow(
      id: asIntOr(json['id']),
      studentId: student == null ? null : asInt(student['id']),
      studentName: student == null ? null : asStr(student['name']),
      studentCode: student == null ? null : student['studentCode'] as String?,
      score: asIntOr(json['score']),
      totalPoints: asIntOr(json['totalPoints']),
      submittedAt: asDate(json['submittedAt']),
    );
  }
}

/// GET /quizzes/{id}
class QuizDetail {
  QuizDetail({
    required this.id,
    required this.title,
    required this.type,
    required this.isGraded,
    this.createdAt,
    this.dueDate,
    this.session,
    required this.totalPoints,
    required this.questions,
    required this.submissions,
  });

  final int id;
  final String title;
  final String type;
  final bool isGraded;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final NamedRef? session;
  final int totalPoints;
  final List<QuizQuestion> questions;
  final List<QuizSubmissionRow> submissions;

  bool get isPastDue => dueDate != null && dueDate!.toLocal().isBefore(DateTime.now());

  factory QuizDetail.fromJson(Map<String, dynamic> json) => QuizDetail(
        id: asIntOr(json['id']),
        title: asStr(json['title']),
        type: asStr(json['type']),
        isGraded: asBool(json['isGraded'], true),
        createdAt: asDate(json['createdAt']),
        dueDate: asDate(json['dueDate']),
        session: json['session'] == null
            ? null
            : NamedRef.fromJson(Map<String, dynamic>.from(json['session'] as Map)),
        totalPoints: asIntOr(json['totalPoints']),
        questions: ((json['questions'] as List?) ?? [])
            .map((e) => QuizQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        submissions: ((json['submissions'] as List?) ?? [])
            .map((e) => QuizSubmissionRow.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
