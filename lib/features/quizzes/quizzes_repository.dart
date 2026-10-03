import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/paginated.dart';
import '../../models/quiz_model.dart';

class QuizzesRepository {
  QuizzesRepository(this._api);
  final ApiClient _api;

  Future<Paginated<QuizListItem>> list({String? search, int page = 1, int pageSize = 10}) async {
    final json = await _api.get(ApiConstants.quizzes, query: {
      'search': search,
      'page': page,
      'pageSize': pageSize,
    });
    return Paginated.fromJson(json, QuizListItem.fromJson);
  }

  Future<QuizDetail> detail(int id) async =>
      QuizDetail.fromJson(await _api.get(ApiConstants.quiz(id)));

  /// POST /quizzes — SessionId is optional (quiz doesn't have to be tied to
  /// a specific session). Each question needs a CorrectAnswer: "A"/"B"/"C"/"D"
  /// for multiple_choice, or "true"/"false" for true_false.
  Future<void> create({
    required String title,
    required String type,
    required bool isGraded,
    DateTime? dueDate,
    int? sessionId,
    required List<Map<String, dynamic>> questions,
  }) =>
      _api.post(ApiConstants.quizzes, data: {
        'title': title,
        'type': type,
        'isGraded': isGraded,
        'dueDate': dueDate?.toIso8601String(),
        'sessionId': sessionId,
        'questions': questions,
      });

  /// PUT /quizzes/{id} — QuizzesController.UpdateQuiz. Replaces the entire
  /// question set, same request shape as create.
  Future<void> update({
    required int quizId,
    required String title,
    required String type,
    required bool isGraded,
    DateTime? dueDate,
    int? sessionId,
    required List<Map<String, dynamic>> questions,
  }) =>
      _api.put(ApiConstants.quiz(quizId), data: {
        'title': title,
        'type': type,
        'isGraded': isGraded,
        'dueDate': dueDate?.toIso8601String(),
        'sessionId': sessionId,
        'questions': questions,
      });

  /// answers: { questionId: "A" | "true" ... }
  Future<Map<String, dynamic>> submit(int id, Map<int, String> answers) => _api.post(
        ApiConstants.quizSubmit(id),
        data: {
          'answers': answers.entries
              .map((e) => {'questionId': e.key, 'answer': e.value})
              .toList(),
        },
      );
}
