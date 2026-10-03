import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_exception.dart';
import '../tickets_repository.dart';

enum CreateTicketStatus { idle, submitting, done, error }

class CreateTicketState extends Equatable {
  const CreateTicketState({this.status = CreateTicketStatus.idle, this.errorMessage});
  final CreateTicketStatus status;
  final String? errorMessage;

  CreateTicketState copyWith({CreateTicketStatus? status, String? errorMessage}) =>
      CreateTicketState(status: status ?? this.status, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}

class CreateTicketCubit extends Cubit<CreateTicketState> {
  CreateTicketCubit(this._repository) : super(const CreateTicketState());
  final TicketsRepository _repository;

  Future<void> submit(String title, String description) async {
    emit(state.copyWith(status: CreateTicketStatus.submitting, errorMessage: null));
    try {
      await _repository.create(title: title, description: description);
      emit(state.copyWith(status: CreateTicketStatus.done));
    } on ApiException catch (e) {
      emit(state.copyWith(status: CreateTicketStatus.error, errorMessage: e.message));
    }
  }
}
