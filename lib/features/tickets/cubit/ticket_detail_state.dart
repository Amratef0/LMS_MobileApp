import 'package:equatable/equatable.dart';
import '../../../models/ticket_model.dart';
import '../../../models/paginated.dart';

enum DetailStatus { initial, loading, ready, error }

class TicketDetailData {
  TicketDetailData.fromJson(Map<String, dynamic> json)
      : id = asIntOr(json['id']),
        title = asStr(json['title']),
        description = asStr(json['description']),
        status = asStr(json['status']),
        createdAt = asDate(json['createdAt']),
        student = json['student'] == null
            ? null
            : TicketStudentRef.fromJson(Map<String, dynamic>.from(json['student'] as Map)),
        replies = ((json['replies'] as List?) ?? [])
            .map((e) => TicketReplyModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime? createdAt;
  final TicketStudentRef? student;
  final List<TicketReplyModel> replies;
}

class TicketDetailState extends Equatable {
  const TicketDetailState({
    this.status = DetailStatus.initial,
    this.data,
    this.sending = false,
    this.errorMessage,
  });

  final DetailStatus status;
  final TicketDetailData? data;
  final bool sending;
  final String? errorMessage;

  TicketDetailState copyWith({
    DetailStatus? status,
    TicketDetailData? data,
    bool? sending,
    String? errorMessage,
  }) =>
      TicketDetailState(
        status: status ?? this.status,
        data: data ?? this.data,
        sending: sending ?? this.sending,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, data, sending, errorMessage];
}
