import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../auth_repository.dart';
import 'auth_state.dart';

/// Owns the whole session lifecycle: boot-time token check, login, logout,
/// and reacting to a 401 raised anywhere else in the app (via
/// [ApiClient.onUnauthorized]).
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository, required ApiClient apiClient})
      : _repository = repository,
        super(const AuthState()) {
    apiClient.onUnauthorized = _handleUnauthorized;
  }

  final AuthRepository _repository;

  Future<void> appStarted() async {
    final cached = await _repository.readCachedUser();
    if (cached == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }
    // Optimistically show the cached user right away, then confirm with the
    // server in the background so a stale/expired token gets caught.
    emit(state.copyWith(status: AuthStatus.authenticated, user: cached));
    try {
      final fresh = await _repository.verifySession();
      emit(state.copyWith(user: fresh));
    } on ApiException {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    try {
      final user = await _repository.login(email.trim(), password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _handleUnauthorized() {
    if (state.status == AuthStatus.authenticated) {
      logout();
    }
  }
}
