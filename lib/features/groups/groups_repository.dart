import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/paginated.dart';
import '../../models/group_model.dart';

class GroupsRepository {
  GroupsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<GroupListItem>> list({String? search, int page = 1, int pageSize = 10}) async {
    final json = await _api.get(ApiConstants.groups, query: {'search': search, 'page': page, 'pageSize': pageSize});
    return Paginated.fromJson(json, GroupListItem.fromJson);
  }

  Future<GroupDetail> detail(int id) async => GroupDetail.fromJson(await _api.get(ApiConstants.group(id)));

  /// POST /groups — GroupsController.CreateGroup. CoordinatorIds is
  /// optional; coordinators can also be assigned later.
  Future<void> create({required String name, required String code, DateTime? startDate, DateTime? endDate}) =>
      _api.post(ApiConstants.groups, data: {
        'name': name,
        'code': code,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      });

  /// POST /groups/{id}/assign-coordinator — Admin only. `replace: true`
  /// clears any existing coordinators on the group first.
  Future<void> assignCoordinator(int groupId, int coordinatorId, {bool replace = false}) =>
      _api.post(ApiConstants.groupAssignCoordinator(groupId), data: {
        'coordinatorId': coordinatorId,
        'replace': replace,
      });

  /// DELETE /groups/{id}/coordinators/{coordId} — Admin only.
  Future<void> removeCoordinator(int groupId, int coordinatorId) =>
      _api.delete(ApiConstants.groupRemoveCoordinator(groupId, coordinatorId));

  /// POST /groups/{id}/teams — Admin/Coordinator.
  Future<void> createTeam(int groupId, {required String name, int? teamLeadId, List<int>? studentIds}) =>
      _api.post(ApiConstants.groupTeams(groupId), data: {
        'name': name,
        'teamLeadId': teamLeadId,
        'studentIds': studentIds,
      });
}
