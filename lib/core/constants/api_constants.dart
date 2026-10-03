/// Central place for the API base URL and every endpoint path.
///
/// These match `backend/LMS.API/Controllers/*.cs` in your .NET solution
/// exactly (same routes, same query params, same JSON shapes) so this app
/// talks to the very same database as the Angular site.
class ApiConstants {
  ApiConstants._();

  /// IMPORTANT — pick the right base URL for how you're running the app:
  ///
  /// • Android EMULATOR  -> keep as-is. 10.0.2.2 is the emulator's alias for
  ///   your Windows machine's "localhost".
  /// • Real Android phone -> replace with your PC's LAN IP, e.g.
  ///   "http://192.168.1.50:5000/api" (also add that IP to
  ///   android/app/src/main/res/xml/network_security_config.xml).
  ///
  /// We use the plain-HTTP port (53788, from `launchSettings.json` — the
  /// `http://localhost:53788` profile) instead of the HTTPS dev-cert port
  /// (53787) so we don't have to teach the app to trust a self-signed
  /// certificate. Double check the port your `dotnet run` actually prints.
  static const String baseUrl = 'http://10.0.2.2:53788/api';

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String changePassword = '/auth/change-password';

  // ── Dashboard ─────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ── Sessions ──────────────────────────────────────────────────────────
  static const String sessions = '/sessions';
  static String session(int id) => '/sessions/$id';
  static String sessionRun(int id) => '/sessions/$id/run';
  static String sessionFinish(int id) => '/sessions/$id/finish';
  static String sessionCancel(int id) => '/sessions/$id/cancel';
  static String sessionAttendance(int id) => '/sessions/$id/attendance';
  static String sessionAttachments(int id) => '/sessions/$id/attachments';
  static String sessionAttachment(int id, int attachId) =>
      '/sessions/$id/attachments/$attachId';
  static String sessionRecordLink(int id) => '/sessions/$id/record-link';

  // ── Groups ────────────────────────────────────────────────────────────
  static const String groups = '/groups';
  static String group(int id) => '/groups/$id';
  static String groupAssignCoordinator(int id) =>
      '/groups/$id/assign-coordinator';
  static String groupRemoveCoordinator(int id, int coordId) =>
      '/groups/$id/coordinators/$coordId';
  static String groupTeams(int id) => '/groups/$id/teams';

  // ── Students ──────────────────────────────────────────────────────────
  static const String students = '/students';
  static String student(int id) => '/students/$id';
  static String studentResetPassword(int id) => '/students/$id/change-password';
  static const String studentMe = '/students/me';

  // ── Instructors ───────────────────────────────────────────────────────
  static const String instructors = '/instructors';
  static String instructor(int id) => '/instructors/$id';
  static String instructorToggleStatus(int id) => '/instructors/$id/toggle-status';

  // ── Quizzes ───────────────────────────────────────────────────────────
  static const String quizzes = '/quizzes';
  static String quiz(int id) => '/quizzes/$id';
  static String quizSubmit(int id) => '/quizzes/$id/submit';
  static String quizSubmissions(int id) => '/quizzes/$id/submissions';

  // ── Assignments ───────────────────────────────────────────────────────
  static const String assignments = '/assignments';
  static String assignment(int id) => '/assignments/$id';
  static String assignmentSubmissions(int id) => '/assignments/$id/submissions';
  static String assignmentSubmit(int id) => '/assignments/$id/submit';
  static String assignmentGrade(int id, int subId) =>
      '/assignments/$id/submissions/$subId/grade';

  // ── Tickets ───────────────────────────────────────────────────────────
  static const String tickets = '/tickets';
  static const String myTickets = '/tickets/my';
  static String ticketReply(int id) => '/tickets/$id/reply';
  static String ticketStatus(int id) => '/tickets/$id/status';

  // ── Users (admin: coordinators) ──────────────────────────────────────
  static const String coordinators = '/users/coordinators';
  static String coordinator(int id) => '/users/coordinators/$id';
  static String coordinatorResetPassword(int id) =>
      '/users/coordinators/$id/reset-password';
  static const String profile = '/users/profile';

  // ── Files ─────────────────────────────────────────────────────────────
  static const String uploadPdf = '/files/upload-pdf';

  // ── Reports (binary downloads: .xlsx / .pdf) ────────────────────────────
  static const String reportAttendance = '/reports/attendance';
  static const String reportGrades = '/reports/grades';
  static const String reportGroupSummary = '/reports/group-summary';
  static const String reportStudentProgress = '/reports/student-progress';
}
