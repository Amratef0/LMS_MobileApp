import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../tickets_repository.dart';
import 'ticket_detail_state.dart';

class TicketDetailCubit extends Cubit<TicketDetailState> {
  TicketDetailCubit(this._repository, this.ticketId) : super(const TicketDetailState());
  final TicketsRepository _repository;
  final int ticketId;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading));
    try {
      final json = await _repository.detailRaw(ticketId);
      emit(state.copyWith(status: DetailStatus.ready, data: TicketDetailData.fromJson(json)));
    } on ApiException catch (e) {
      emit(state.copyWith(status: DetailStatus.error, errorMessage: e.message));
    }
  }

  Future<void> reply(String message) async {
    emit(state.copyWith(sending: true, errorMessage: null));
    try {
      await _repository.reply(ticketId, message);
      emit(state.copyWith(sending: false));
      await load();
    } on ApiException catch (e) {
      emit(state.copyWith(sending: false, errorMessage: e.message));
    }
  }

  Future<void> updateStatus(String status) async {
    try {
      await _repository.updateStatus(ticketId, status);
      await load();
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }
}
