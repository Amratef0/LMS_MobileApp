import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/paginated.dart';
import '../../models/user_model.dart';

class CoordinatorModel {
  CoordinatorModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
    required this.groupsCount,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final int groupsCount;

  factory CoordinatorModel.fromJson(Map<String, dynamic> json) => CoordinatorModel(
        id: asIntOr(json['id']),
        name: asStr(json['name']),
        email: asStr(json['email']),
        phone: json['phone'] as String?,
        isActive: asBool(json['isActive'], true),
        groupsCount: asIntOr(json['groupsCount']),
      );
}

/// Wraps UsersController's `/users/coordinators` endpoints — Admin-only,
/// used to manage coordinator accounts and (from the Groups screen) to
/// assign a coordinator to a group.
class CoordinatorsRepository {
  CoordinatorsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<CoordinatorModel>> list({String? search, int page = 1, int pageSize = 20}) async {
    final json = await _api.get(ApiConstants.coordinators, query: {
      'search': search,
      'page': page,
      'pageSize': pageSize,
    });
    return Paginated.fromJson(json, CoordinatorModel.fromJson);
  }

  Future<void> create({required String name, required String email, required String password, String? phone}) =>
      _api.post(ApiConstants.coordinators, data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });
}
