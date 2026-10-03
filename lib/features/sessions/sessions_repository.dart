import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/paginated.dart';
import '../../models/session_model.dart';

class SessionsRepository {
  SessionsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<SessionListItem>> list({
    String? search,
    String? status,
    String? type,
    String? topic,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json = await _api.get(ApiConstants.sessions, query: {
      'search': search,
      'status': status,
      'type': type,
      'topic': topic,
      'page': page,
      'pageSize': pageSize,
    });
    return Paginated.fromJson(json, SessionListItem.fromJson);
  }

  Future<SessionDetail> detail(int id) async =>
      SessionDetail.fromJson(await _api.get(ApiConstants.session(id)));

  Future<void> create({
    required String name,
    required int trainerId,
    required int groupId,
    required DateTime sessionDate,
    required String type,
    required String topic,
    String? location,
    String? recordLink,
  }) =>
      _api.post(ApiConstants.sessions, data: {
        'name': name,
        'trainerId': trainerId,
        'groupId': groupId,
        'sessionDate': sessionDate.toIso8601String(),
        'type': type,
        'topic': topic,
        'location': location,
        'recordLink': recordLink,
      });

  /// PUT /sessions/{id} — SessionsController.UpdateSession. Note: unlike
  /// create, the group can't be changed once a session exists (no GroupId
  /// field on UpdateSessionRequest), and this doesn't touch the record link
  /// (that has its own PUT /sessions/{id}/record-link endpoint).
  Future<void> update(
    int id, {
    required String name,
    required int trainerId,
    required DateTime sessionDate,
    required String type,
    required String topic,
    String? location,
  }) =>
      _api.put(ApiConstants.session(id), data: {
        'name': name,
        'trainerId': trainerId,
        'sessionDate': sessionDate.toIso8601String(),
        'type': type,
        'topic': topic,
        'location': location,
      });

  Future<void> run(int id) => _api.post(ApiConstants.sessionRun(id));  Future<void> finish(int id) => _api.post(ApiConstants.sessionFinish(id));
  Future<void> cancel(int id) => _api.post(ApiConstants.sessionCancel(id));

  Future<List<AttendanceRow>> getAttendance(int id) async {
    final list = await _api.getList(ApiConstants.sessionAttendance(id));
    return list.map((e) => AttendanceRow.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> saveAttendance(int id, List<AttendanceRow> rows) => _api.post(
        ApiConstants.sessionAttendance(id),
        data: rows.map((r) => {'studentId': r.studentId, 'joined': r.joined}).toList(),
      );

  Future<void> updateRecordLink(int id, String link) => _api.put(
        ApiConstants.sessionRecordLink(id),
        data: {'recordLink': link},
      );

  Future<void> addAttachment(int id, {
    required String title,
    required String attachmentType,
    String? fileUrl,
    String? link,
  }) =>
      _api.post(ApiConstants.sessionAttachments(id), data: {
        'title': title,
        'attachmentType': attachmentType,
        'fileUrl': fileUrl,
        'link': link,
      });

  Future<void> deleteAttachment(int sessionId, int attachId) =>
      _api.delete(ApiConstants.sessionAttachment(sessionId, attachId));
}
