import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/paginated.dart';
import '../../models/assignment_model.dart';

class AssignmentsRepository {
  AssignmentsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<AssignmentListItem>> list({String? search, int page = 1, int pageSize = 10}) async {
    final json = await _api.get(ApiConstants.assignments, query: {
      'search': search,
      'page': page,
      'pageSize': pageSize,
    });
    return Paginated.fromJson(json, AssignmentListItem.fromJson);
  }

  Future<Map<String, dynamic>> detailRaw(int id) => _api.get(ApiConstants.assignment(id));

  /// POST /assignments — AssignmentsController.CreateAssignment.
  Future<void> create({
    required String title,
    String? description,
    required bool isGraded,
    DateTime? dueDate,
    int? sessionId,
  }) =>
      _api.post(ApiConstants.assignments, data: {
        'title': title,
        'description': description,
        'isGraded': isGraded,
        'dueDate': dueDate?.toIso8601String(),
        'sessionId': sessionId,
      });

  /// PUT /assignments/{id} — AssignmentsController.UpdateAssignment.
  Future<void> update({
    required int assignmentId,
    required String title,
    String? description,
    required bool isGraded,
    DateTime? dueDate,
    int? sessionId,
  }) =>
      _api.put(ApiConstants.assignment(assignmentId), data: {
        'title': title,
        'description': description,
        'isGraded': isGraded,
        'dueDate': dueDate?.toIso8601String(),
        'sessionId': sessionId,
      });

  Future<void> submitFile(int id, String fileUrl) => _api.post(
        ApiConstants.assignmentSubmit(id),
        data: {'submissionType': 'file', 'fileUrl': fileUrl},
      );

  Future<void> submitLink(int id, String link) => _api.post(
        ApiConstants.assignmentSubmit(id),
        data: {'submissionType': 'link', 'link': link},
      );

  Future<String> uploadFile(String path, String name) => _api.uploadPdf(path, name);

  Future<void> grade(int assignmentId, int submissionId, {required int grade, String? feedback}) =>
      _api.put(
        ApiConstants.assignmentGrade(assignmentId, submissionId),
        // Matches the API's `record GradeRequest(int Grade, string? Feedback)`
        // exactly — this used to send "gradeFeedback" which the backend
        // would silently ignore (model binder just leaves Feedback null).
        data: {'grade': grade, 'feedback': feedback},
      );
}
