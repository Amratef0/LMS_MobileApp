import 'paginated.dart';

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String role; // "Admin" | "Coordinator" | "Student"

  bool get isAdmin => role == 'Admin';
  bool get isCoordinator => role == 'Coordinator';
  bool get isStudent => role == 'Student';
  bool get isStaff => isAdmin || isCoordinator;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        email: asStr(json['email']),
        role: asStr(json['role']),
      );
}

class GroupRef {
  GroupRef({required this.id, required this.name, this.code});
  final int id;
  final String name;
  final String? code;

  factory GroupRef.fromJson(Map<String, dynamic> json) => GroupRef(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        code: json['code'] as String?,
      );
}

/// GET /students/me — student's own profile + attendance summary.
class StudentProfile {
  StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.city,
    this.gender,
    this.studentCode,
    required this.groups,
    required this.attendanceRate,
    required this.totalSessions,
    required this.attended,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? city;
  final String? gender;
  final String? studentCode;
  final List<GroupRef> groups;
  final double attendanceRate;
  final int totalSessions;
  final int attended;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final stats = json['attendanceStats'] as Map? ?? {};
    return StudentProfile(
      id: asIntOr(json['id']),
      name: asStr(json['name']),
      email: asStr(json['email']),
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      gender: json['gender'] as String?,
      studentCode: json['studentCode'] as String?,
      groups: ((json['groups'] as List?) ?? [])
          .map((e) => GroupRef.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      attendanceRate: asDouble(stats['rate']),
      totalSessions: asIntOr(stats['totalSessions']),
      attended: asIntOr(stats['attended']),
    );
  }
}
