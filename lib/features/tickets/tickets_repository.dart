import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../models/paginated.dart';
import '../../models/ticket_model.dart';

class TicketsRepository {
  TicketsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<TicketListItem>> list({
    required bool isStudent,
    String? search,
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json = await _api.get(
      isStudent ? ApiConstants.myTickets : ApiConstants.tickets,
      query: {'search': search, 'status': status, 'page': page, 'pageSize': pageSize},
    );
    return Paginated.fromJson(json, TicketListItem.fromJson);
  }

  Future<Map<String, dynamic>> detailRaw(int id) => _api.get('${ApiConstants.tickets}/$id');

  Future<void> create({required String title, required String description}) => _api.post(
        ApiConstants.tickets,
        data: {'title': title, 'description': description},
      );

  Future<void> reply(int id, String message) =>
      _api.post(ApiConstants.ticketReply(id), data: {'message': message});

  Future<void> updateStatus(int id, String status) =>
      _api.put(ApiConstants.ticketStatus(id), data: {'status': status});
}
