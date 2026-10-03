import 'paginated.dart';

/// GET /dashboard — Student variant (role == "Student").
class StudentDashboard {
  StudentDashboard({
    required this.attendanceTotal,
    required this.attendanceAttended,
    required this.attendanceMissed,
    required this.attendanceRate,
    required this.scorePointsObtained,
    required this.scoreTotalPoints,
    required this.scorePercentage,
    required this.quizzesTotal,
    required this.quizzesTaken,
    required this.quizzesPending,
    required this.quizzesMissed,
    required this.assignmentsTotal,
    required this.assignmentsSubmitted,
    required this.assignmentsPending,
    required this.assignmentsMissed,
    required this.ticketsTotal,
    required this.ticketsOpen,
    required this.upcomingDeadlines,
  });

  final int attendanceTotal, attendanceAttended, attendanceMissed;
  final double attendanceRate;
  final int scorePointsObtained, scoreTotalPoints;
  final double scorePercentage;
  final int quizzesTotal, quizzesTaken, quizzesPending, quizzesMissed;
  final int assignmentsTotal, assignmentsSubmitted, assignmentsPending, assignmentsMissed;
  final int ticketsTotal, ticketsOpen;
  final List<UpcomingDeadline> upcomingDeadlines;

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    final att = json['attendance'] as Map? ?? {};
    final score = json['scoreReport'] as Map? ?? {};
    final quizzes = json['quizzes'] as Map? ?? {};
    final assignments = json['assignments'] as Map? ?? {};
    final tickets = json['tickets'] as Map? ?? {};
    return StudentDashboard(
      attendanceTotal: asIntOr(att['totalSessions']),
      attendanceAttended: asIntOr(att['attended']),
      attendanceMissed: asIntOr(att['missed']),
      attendanceRate: asDouble(att['rate']),
      scorePointsObtained: asIntOr(score['pointsObtained']),
      scoreTotalPoints: asIntOr(score['totalPoints']),
      scorePercentage: asDouble(score['percentage']),
      quizzesTotal: asIntOr(quizzes['total']),
      quizzesTaken: asIntOr(quizzes['taken']),
      quizzesPending: asIntOr(quizzes['pending']),
      quizzesMissed: asIntOr(quizzes['missed']),
      assignmentsTotal: asIntOr(assignments['total']),
      assignmentsSubmitted: asIntOr(assignments['submitted']),
      assignmentsPending: asIntOr(assignments['pending']),
      assignmentsMissed: asIntOr(assignments['missed']),
      ticketsTotal: asIntOr(tickets['total']),
      ticketsOpen: asIntOr(tickets['open']),
      upcomingDeadlines: ((json['upcomingDeadlines'] as List?) ?? [])
          .map((e) => UpcomingDeadline.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class UpcomingDeadline {
  UpcomingDeadline({required this.type, required this.title, this.dueDate, this.sessionName});
  final String type; // quiz | assignment
  final String title;
  final DateTime? dueDate;
  final String? sessionName;

  factory UpcomingDeadline.fromJson(Map<String, dynamic> json) => UpcomingDeadline(
        type: asStr(json['type']),
        title: asStr(json['title']),
        dueDate: asDate(json['dueDate']),
        sessionName: json['sessionName'] as String?,
      );
}

/// GET /dashboard — Admin/Coordinator variant.
class StaffDashboard {
  StaffDashboard({
    required this.role,
    required this.totalStudents,
    required this.totalAssessments,
    required this.totalQuizzes,
    required this.avgRating,
    required this.sessionsTotal,
    required this.sessionsFinished,
    required this.sessionsPending,
    required this.sessionsRunning,
    required this.attendanceTotal,
    required this.attendanceJoined,
    required this.attendanceJoinRate,
    required this.assignmentsTotal,
    required this.assignmentsSubmitted,
    required this.assignmentsRate,
    required this.genderMale,
    required this.genderFemale,
  });

  final String role;
  final int totalStudents, totalAssessments, totalQuizzes;
  final double avgRating;
  final int sessionsTotal, sessionsFinished, sessionsPending, sessionsRunning;
  final int attendanceTotal, attendanceJoined;
  final double attendanceJoinRate;
  final int assignmentsTotal, assignmentsSubmitted;
  final double assignmentsRate;
  final int genderMale, genderFemale;

  factory StaffDashboard.fromJson(Map<String, dynamic> json) {
    final sessions = json['sessions'] as Map? ?? {};
    final attendance = json['attendance'] as Map? ?? {};
    final assignments = json['assignments'] as Map? ?? {};
    final gender = json['gender'] as Map? ?? {};
    return StaffDashboard(
      role: asStr(json['role']),
      totalStudents: asIntOr(json['totalStudents']),
      totalAssessments: asIntOr(json['totalAssessments']),
      totalQuizzes: asIntOr(json['totalQuizzes']),
      avgRating: asDouble(json['avgRating']),
      sessionsTotal: asIntOr(sessions['total']),
      sessionsFinished: asIntOr(sessions['finished']),
      sessionsPending: asIntOr(sessions['pending']),
      sessionsRunning: asIntOr(sessions['running']),
      attendanceTotal: asIntOr(attendance['total']),
      attendanceJoined: asIntOr(attendance['joined']),
      attendanceJoinRate: asDouble(attendance['joinRate']),
      assignmentsTotal: asIntOr(assignments['total']),
      assignmentsSubmitted: asIntOr(assignments['submitted']),
      assignmentsRate: asDouble(assignments['rate']),
      genderMale: asIntOr(gender['male']),
      genderFemale: asIntOr(gender['female']),
    );
  }
}
