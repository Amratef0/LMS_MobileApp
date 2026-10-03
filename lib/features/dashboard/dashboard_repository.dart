import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/dashboard_model.dart';

class DashboardRepository {
  DashboardRepository(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> fetchRaw() => _api.get(ApiConstants.dashboard);

  Future<StudentDashboard> fetchStudent() async =>
      StudentDashboard.fromJson(await fetchRaw());

  Future<StaffDashboard> fetchStaff() async =>
      StaffDashboard.fromJson(await fetchRaw());
}
