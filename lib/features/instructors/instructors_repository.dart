import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/paginated.dart';
import '../../models/instructor_model.dart';

class InstructorsRepository {
  InstructorsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<InstructorModel>> list({String? search, int page = 1, int pageSize = 10}) async {
    final json = await _api.get(ApiConstants.instructors, query: {'search': search, 'page': page, 'pageSize': pageSize});
    return Paginated.fromJson(json, InstructorModel.fromJson);
  }

  Future<void> create({required String name, String? email, String? phone, String? bio}) =>
      _api.post(ApiConstants.instructors, data: {'name': name, 'email': email, 'phone': phone, 'bio': bio});

  Future<void> toggleStatus(int id) => _api.put(ApiConstants.instructorToggleStatus(id));
}
