import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/paginated.dart';
import '../../models/student_model.dart';
import '../../models/user_model.dart';

class StudentsRepository {
  StudentsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<StudentListItem>> list({
    String? search,
    int? groupId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json = await _api.get(ApiConstants.students, query: {
      'search': search,
      'groupId': groupId,
      'page': page,
      'pageSize': pageSize,
    });
    return Paginated.fromJson(json, StudentListItem.fromJson);
  }

  Future<StudentProfile> myProfile() async =>
      StudentProfile.fromJson(await _api.get(ApiConstants.studentMe));

  Future<void> create({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? city,
    String? gender,
    int? groupId,
  }) =>
      _api.post(ApiConstants.students, data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'city': city,
        'gender': gender,
        'groupId': groupId,
      });

  Future<void> toggleActive(int id, bool isActive) =>
      _api.put(ApiConstants.student(id), data: {'isActive': isActive});
}
