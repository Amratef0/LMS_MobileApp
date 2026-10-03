import 'paginated.dart';

class InstructorModel {
  InstructorModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.bio,
    required this.isActive,
    this.sessionsCount = 0,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? bio;
  final bool isActive;
  final int sessionsCount;

  factory InstructorModel.fromJson(Map<String, dynamic> json) => InstructorModel(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        bio: json['bio'] as String?,
        isActive: asBool(json['isActive'], true),
        sessionsCount: asIntOr(json['sessionsCount']),
      );
}
