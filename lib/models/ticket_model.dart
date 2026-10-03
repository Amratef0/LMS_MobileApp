import 'paginated.dart';

class TicketStudentRef {
  TicketStudentRef({required this.id, required this.name, this.email, this.groupName});
  final int id;
  final String name;
  final String? email;
  final String? groupName;

  factory TicketStudentRef.fromJson(Map<String, dynamic> json) => TicketStudentRef(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        email: json['email'] as String?,
        groupName: json['groupName'] as String?,
      );
}

/// One row from GET /tickets (Admin/Coordinator) or GET /tickets/my (Student).
class TicketListItem {
  TicketListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.createdAt,
    this.student,
    this.repliesCount = 0,
  });

  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime? createdAt;
  final TicketStudentRef? student;
  final int repliesCount;

  factory TicketListItem.fromJson(Map<String, dynamic> json) => TicketListItem(
        id: asIntOr(json['id']),
        title: asStr(json['title']),
        description: asStr(json['description']),
        status: asStr(json['status']),
        createdAt: asDate(json['createdAt']),
        student: json['student'] == null
            ? null
            : TicketStudentRef.fromJson(Map<String, dynamic>.from(json['student'] as Map)),
        repliesCount: asIntOr(json['repliesCount']),
      );
}

class TicketReplyModel {
  TicketReplyModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    this.createdAt,
  });

  final int id;
  final int userId;
  final String userName;
  final String message;
  final DateTime? createdAt;

  factory TicketReplyModel.fromJson(Map<String, dynamic> json) => TicketReplyModel(
        id: asIntOr(json['id']),
        userId: asIntOr(json['userId']),
        userName: asStr(json['user'] is Map ? (json['user']['name'] ?? '') : (json['userName'] ?? '')),
        message: asStr(json['message']),
        createdAt: asDate(json['createdAt']),
      );
}
