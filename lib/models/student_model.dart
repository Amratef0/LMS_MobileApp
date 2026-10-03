import 'paginated.dart';

/// One row from GET /students.
class StudentListItem {
  StudentListItem({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.nationalId,
    this.city,
    this.gender,
    required this.isActive,
    this.studentCode,
    this.groupName,
    this.groupId,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? nationalId;
  final String? city;
  final String? gender;
  final bool isActive;
  final String? studentCode;
  final String? groupName;
  final int? groupId;

  factory StudentListItem.fromJson(Map<String, dynamic> json) => StudentListItem(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        email: asStr(json['email']),
        phone: json['phone'] as String?,
        nationalId: json['nationalId'] as String?,
        city: json['city'] as String?,
        gender: json['gender'] as String?,
        isActive: asBool(json['isActive'], true),
        studentCode: json['studentCode'] as String?,
        groupName: json['groupName'] as String?,
        groupId: asInt(json['groupId']),
      );
}
