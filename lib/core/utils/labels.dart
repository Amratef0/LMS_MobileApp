/// Central place for turning raw API status/type strings into the English
/// labels shown in the UI (matches the Angular site's English strings).
class Labels {
  Labels._();

  static String sessionStatus(String s) => switch (s) {
        'finished' => 'Finished',
        'pending' => 'Pending',
        'running' => 'Running',
        'cancelled' => 'Cancelled',
        _ => s,
      };

  static String sessionType(String t) => t == 'live' ? 'Live (Online)' : 'On-site';

  static String sessionTopic(String t) => t == 'technical' ? 'Technical' : 'Soft Skills';

  static String ticketStatus(String s) => switch (s) {
        'in_progress' => 'In Progress',
        'resolved' => 'Resolved',
        'closed' => 'Closed',
        'reopened' => 'Reopened',
        _ => s,
      };

  static String quizType(String t) => t == 'multiple_choice' ? 'Multiple Choice' : 'True / False';

  static String submissionStatus(String s) => switch (s) {
        'submitted' => 'Submitted',
        'missed' => 'Missed',
        'pending' => 'Pending',
        _ => s,
      };

  static String gender(String? g) => switch (g) {
        'Male' => 'Male',
        'Female' => 'Female',
        _ => '-',
      };

  static String role(String r) => switch (r) {
        'Admin' => 'Admin',
        'Coordinator' => 'Coordinator',
        'Student' => 'Student',
        _ => r,
      };
}
