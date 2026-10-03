import 'paginated.dart';
import 'user_model.dart';

class CoordinatorRef {
  CoordinatorRef({required this.id, required this.name, this.email});
  final int id;
  final String name;
  final String? email;

  factory CoordinatorRef.fromJson(Map<String, dynamic> json) => CoordinatorRef(
        id: asIntOr(json['id'] ?? json['coordinatorId']),
        name: asStr(json['name']),
        email: json['email'] as String?,
      );
}

/// One row from GET /groups.
class GroupListItem {
  GroupListItem({
    required this.id,
    required this.name,
    required this.code,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.coordinators,
    required this.studentsCount,
  });

  final int id;
  final String name;
  final String code;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<CoordinatorRef> coordinators;
  final int studentsCount;

  factory GroupListItem.fromJson(Map<String, dynamic> json) => GroupListItem(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        code: asStr(json['code']),
        startDate: asDate(json['startDate']),
        endDate: asDate(json['endDate']),
        isActive: asBool(json['isActive'], true),
        coordinators: ((json['coordinators'] as List?) ?? [])
            .map((e) => CoordinatorRef.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        studentsCount: asIntOr(json['studentsCount']),
      );
}

class GroupStudentRef {
  GroupStudentRef({required this.id, required this.name, this.email, this.studentCode});
  final int id;
  final String name;
  final String? email;
  final String? studentCode;

  factory GroupStudentRef.fromJson(Map<String, dynamic> json) => GroupStudentRef(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        email: json['email'] as String?,
        studentCode: json['studentCode'] as String?,
      );
}

class TeamSummary {
  TeamSummary({required this.id, required this.name, this.createdAt, required this.studentsCount});
  final int id;
  final String name;
  final DateTime? createdAt;
  final int studentsCount;

  factory TeamSummary.fromJson(Map<String, dynamic> json) => TeamSummary(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        createdAt: asDate(json['createdAt']),
        studentsCount: asIntOr(json['studentsCount']),
      );
}

/// GET /groups/{id}
class GroupDetail {
  GroupDetail({
    required this.id,
    required this.name,
    required this.code,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.coordinators,
    required this.students,
    required this.teams,
  });

  final int id;
  final String name;
  final String code;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<CoordinatorRef> coordinators;
  final List<GroupStudentRef> students;
  final List<TeamSummary> teams;

  factory GroupDetail.fromJson(Map<String, dynamic> json) => GroupDetail(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        code: asStr(json['code']),
        startDate: asDate(json['startDate']),
        endDate: asDate(json['endDate']),
        isActive: asBool(json['isActive'], true),
        coordinators: ((json['coordinators'] as List?) ?? [])
            .map((e) => CoordinatorRef.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        students: ((json['students'] as List?) ?? [])
            .map((e) => GroupStudentRef.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        teams: ((json['teams'] as List?) ?? [])
            .map((e) => TeamSummary.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
